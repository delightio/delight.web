class AmazonCredential
  def initialize
    @cached = CachedHash.new "#{self.class}", 15.minutes
  end

  def get
    # Expired hash will return an empty hash.
    # Check for empty? instead to save an extra round trip to Redis.
    credential = @cached.get
    return credential unless credential.empty?

    @cached.set session.credentials
  end

  private
  def session
    policy = AWS::STS::Policy.new
    policy.allow(:actions => :any, :resource => :any)
    AWS::STS.new.new_federated_session("session",
                                       :policy => policy,
                                       :duration => 1.hours)
  end
end