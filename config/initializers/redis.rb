require 'redis'

uri = URI.parse(ENV["REDISTOGO_URL"])
REDIS = Redis.new(host: uri.host, port: uri.port, db: uri.path[1..-1],
                  password: uri.password)

Resque.redis = REDIS
