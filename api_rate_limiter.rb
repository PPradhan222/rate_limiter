require_relative './api_rate_limiter/blacklister'
require_relative './api_rate_limiter/whitelister'
require_relative './api_rate_limiter/throttler'
require_relative './api_rate_limiter/limiters_handler'
require_relative './api_rate_limiter/cache'
require_relative './api_rate_limiter/redis_client'
require_relative './api_rate_limiter/request'
require 'forwardable'

module RateLimiter
  
  # this class is the entry point of all the requested calls
  class ApiRateLimiter
    attr_accessor :limiters_handler

    # initialize the class by initiating limiter handler to handle our limite conditions.
    def initialize
      @limiters_handler = LimitersHandler.new
    end

    # request check through all the whitelisted, blacklisted & throttling conditions.
    def call(request)
      return bad_request unless request.instance_of? Request

      return ok if limiters_handler.whitelisted?(request)
      return not_allowed if limiters_handler.blacklisted?(request)
      
      # check through all the available throttlers, if throttling condition matched with the request,
      # it checks if limit has been exhausted or not.
      limiters_handler.throttlers.each do |name, throttler|
        if throttler.matched?(request)
          return throttler.call(request)
        end
      end
      ok
    end

    # used defined methods of limiter handler to access them from this entry point class.
    extend Forwardable
      def_delegators(
        :@limiters_handler,
        :create_whitelister,
        :create_blacklister,
        :create_throttler
      )

    private

    def bad_request
      {status: 400, body_text: 'Bad Request'}
    end

    def ok
      {status: 200, body_text: 'OK'}
    end

    def not_allowed
      {status: 405, body_text: 'Not Allowed'}
    end
  end
end
