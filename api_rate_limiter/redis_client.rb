require 'redis'

module RateLimiter
  class ApiRateLimiter
    
    # redis client of cache
    class RedisClient
      attr_accessor :redis

      def initialize
        @redis = Redis.new
      end

      def increment(key)
        redis.incr(key)
      end

      def get(key)
        redis.get(key).to_i
      end

      def time_left(key)
        redis.ttl(key)
      end

      def set_expiry(key, time)
        redis.expire(key, time)
      end
    end
  end
end