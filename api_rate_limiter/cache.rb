module RateLimiter
  class ApiRateLimiter
    
    # using cache to store user request data for throttling.
    # to have support option to user to use different type of cache, cache has been generalized.
    class Cache
      attr_accessor :cache

      # currently, redis is used as default cache client
      def initialize(cache = RedisClient.new)
        @cache = cache
      end

      # used to increment cache value corresponding to key
      def increment(key)
        cache.increment(key)
      end

      # get the value of passed key from cache
      def get(key)
        cache.get(key)
      end

      # find out time left for the request limits to be refreshed
      def time_left(key)
        cache.time_left(key)
      end

      # set expire time on cache key, so that after mentioned time period user will get fresh request limits.
      def set_expiry(key, time)
        cache.set_expiry(key, time)
      end
    end
  end
end