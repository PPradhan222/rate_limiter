module RateLimiter
  class ApiRateLimiter

    # The throttler currently using tocket bucket algorithm to validate request corresponding to its limit available.
    class Throttler
      attr_accessor :cache, :block, :request_allowed, :time_window

      # initialize throttler with request and time limit including name of the throttler.
      def initialize(name, request_allowed, time_window, &block)

        # verify the sanity of passed parameters.
        verify_parameters(request_allowed, time_window)

        @cache = Cache.new
        @request_allowed = request_allowed
        @time_window = time_window
        @block = block
      end

      # check if the passed request matches with the throttler condition.
      # create_throttler('throttle login requests', 4, 120) { |request| request.path.include?('/login') }
      def matched?(request)
        block.call(request)
      end

      # after matching, this method handle the user throttling according to its ip.
      # it first check if request_allowed or not based on the limit user has used till now
      # after that its respond with the corresponding response
      def call(request)
        key = request_key(request)
        status_code = 429
        if request_allowed?(key)
          cache.set_expiry(key, time_window) if consume_limit(key) == 1
          status_code = 200
        end
        response_message(key, status_code)
      end

      def request_allowed?(key)
        limit_consumed(key) < request_allowed
      end

      private
      
      def verify_parameters(request_allowed, time_window)
        if !(request_allowed.is_a?(Integer)) || request_allowed < 0
          raise "request_allowed must be a positive integer."
        end

        # time_window is in seconds
        if !(time_window.is_a?(Integer)) || time_window < 0
          raise "time_window must be a positive integer"
        end
      end

      def consume_limit(key)
        cache.increment(key)
      end

      def limit_consumed(key)
        cache.get(key)
      end

      def response_message(key, status_code)
        body_text = "#{ request_allowed - limit_consumed(key) } requests left, new requests will be alloted after #{cache.time_left(key)} seconds"
        { status: status_code, body_text: body_text }
      end

      # currently, request's ip has been used for cache key, but down the line we can add customized key as well.
      def request_key(request)
        request.ip
      end
    end
  end
end
