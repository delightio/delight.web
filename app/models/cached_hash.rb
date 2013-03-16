class CachedHash
  def initialize key, max_ttl
    @key = key
    @max_ttl = max_ttl
  end

  def ttl
    REDIS.ttl @key
  end

  def expired?
    ttl == -1
  end

  def set new_hash
    REDIS.hmset @key, *new_hash.to_a.flatten
    REDIS.expire @key, @max_ttl
    get
  end

  def get
    REDIS.hgetall @key
  end
end