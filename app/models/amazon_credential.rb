class AmazonCredential
  def initialize
    @credentials = CachedHash.new "#{self.class}_Credentials", 15.minutes
  end

  def get
    return @credentials.get unless @credentials.expired?
    @credentials.set session.credentials
  end

  def session
    policy = AWS::STS::Policy.new
    policy.allow(:actions => :any, :resource => :any)
    AWS::STS.new.new_federated_session("session",
                                       :policy => policy,
                                       :duration => 1.hours)
  end
end

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