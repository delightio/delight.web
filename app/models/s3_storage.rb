class S3Storage

  SESSION_DURATION = 3600 # 1 hour
  SESSION_RENEW_INTERVAL = 50.minutes # a bit earlier than the session expiration

  def initialize filename
    @filename = filename
  end

  def bucket_name
    @bucket_name ||= ENV['S3_UPLOAD_BUCKET']
  end

  def presigned_bucket
    return $s3_presigned_bucket if $s3_presigned_bucket and $s3_last_session and $s3_last_session > SESSION_RENEW_INTERVAL.ago

    policy = AWS::STS::Policy.new
    policy.allow(:actions => :any, :resource => :any)
    session = AWS::STS.new.new_federated_session("session", :policy => policy, :duration => SESSION_DURATION)
    s3 = AWS::S3.new(session.credentials)

    $s3_last_session = Time.now
    $s3_presigned_bucket = s3.buckets[bucket_name]
  end

  def presigned_object
    presigned_bucket.objects[@filename]
  end

  def presigned_write_uri
    presigned_object.url_for :write
  end

  def presigned_read_uri
    presigned_object.url_for :read
  end
end
