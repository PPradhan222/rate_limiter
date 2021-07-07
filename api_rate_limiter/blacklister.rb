module RateLimiter
  class ApiRateLimiter
    
    # this class create blacklisting condition, and request are matched by the matched? method of the class.
    class BlackLister
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
