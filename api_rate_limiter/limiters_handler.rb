module RateLimiter
  class ApiRateLimiter
    # this class is basically to handle and create limiting conditions on request.
    class LimitersHandler
      attr_accessor :throttlers, :blacklisters, :whitelisters

      # at the initialization we create empty hashes to store throttlers, blacklisters and whitelisters conditions.
      def initialize
        @throttlers = {}
        @whitelisters = {}
        @blacklisters = {}
      end

      # create throttlers with condition mentioned in block
      def create_throttler(name, request_allowed, time_window, &block)
        throttlers[name] = Throttler.new(name, request_allowed, time_window, &block)
      end

      # create blacklisters with condition mentioned in block
      def create_blacklister(name, &block)
        blacklisters[name] = BlackLister.new(name, &block)
      end

      # crete whitelisters with condition mentioned in block
      def create_whitelister(name, &block)
        whitelisters[name] = WhiteLister.new(name, &block)
      end

      # check if the request matches any blacklisting condition
      def blacklisted?(request)
        blacklisters.any? { |name, blacklister| blacklister.matched?(request) }
      end

      # check if the request matches any whitelisting condition
      def whitelisted?(request)
        whitelisters.any? { |name, whitelister| whitelister.matched?(request) }
      end
    end
  end
end