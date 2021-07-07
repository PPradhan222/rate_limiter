module RateLimiter
  class ApiRateLimiter
    
    # this class create whitelisting condition, and request are matched by the matched? method of the class.
    # whitelister and blacklister class are almost similar, they can be generalized.
    class WhiteLister
      attr_accessor :block

      def initialize(name, &block)
        @name = name
        @block = block
      end

      def matched?(request)
        block.call(request)
      end
    end
  end
end
