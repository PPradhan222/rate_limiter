module RateLimiter
  class ApiRateLimiter
    
    # we are using an customized request class to create requests and pass this request to api rate limiter.
    # this are done to make consistency among passed requests.
    class Request
      attr_accessor :ip, :path, :method

      def initialize(ip, path, method: 'get')
        @ip = ip
        @path = path
        @method = method
      end
    end
  end
end
