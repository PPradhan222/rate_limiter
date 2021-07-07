<!-- Description -->

The ApiRateLimiter is using Token Bucket algorithm to throttle request, though it will face problem of incosistency if it scale to distributed system. But for the simple single system application it won't create much problem.
For distributed sytesm, Slinding Window Counter algorith can be used with redis.
In this algorithm, every request increment the limit_count by 1, till it reaches the threshold, after that it will not allow to make request till the time_period completed to allot new request limit.
It allows to create throttlers with request_limt ,time_window, and condition on which the request is expected to throttled.
Apart from throttling it allows to create blacklist and whitelist for mentioned conditon.
It use customized request to make consitency among all request, currently request contains ip, path and method fields.

<!-- Testing performed on console -->

api_rate_limiter = RateLimiter::ApiRateLimiter.new
api_rate_limiter.create_blacklister('block admin requests') { |request| request.path.include?('/admin') }
api_rate_limiter.create_whitelister('allow signup requests') { |request| request.path.include?('/signup') }
api_rate_limiter.create_throttler('throttle login requests', 4, 120) { |request| request.path.include?('/login') }
request1 = RateLimiter::ApiRateLimiter::Request.new('124.0.0.1', '/admin')
request2 = RateLimiter::ApiRateLimiter::Request.new('124.0.0.1', '/signup')
request3 = RateLimiter::ApiRateLimiter::Request.new('124.0.0.2', '/admin')
request4 = RateLimiter::ApiRateLimiter::Request.new('124.0.0.2', '/signup')
request5 = RateLimiter::ApiRateLimiter::Request.new('124.0.0.2', '/login')
request6 = RateLimiter::ApiRateLimiter::Request.new('124.0.0.3', '/users')
request7 = RateLimiter::ApiRateLimiter::Request.new('192.10.10.1', '/users')

api_rate_limiter.call request1
=> {:status=>405, :body_text=>"Not Allowed"}

api_rate_limiter.call request2
=> {:status=>200, :body_text=>"OK"}

api_rate_limiter.call request3
 => {:status=>405, :body_text=>"Not Allowed"}

api_rate_limiter.call request4
=> {:status=>200, :body_text=>"OK"}

api_rate_limiter.call request5
=> {:status=>200, :body_text=>"3 requests left, new requests will be alloted after 120 seconds"}

after 4 requests
api_rate_limiter.call request5
 => {:status=>429, :body_text=>"0 requests left, new requests will be alloted after 106 seconds"}

 <!--  -->
