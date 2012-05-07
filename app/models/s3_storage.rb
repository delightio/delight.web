class S3Storage
  def initialize filename
    @filename = filename
  end

  def bucket_name
    @bucket_name ||= ENV['S3_UPLOAD_BUCKET']
  end

  def presigned_bucket
    return @presigned_bucket if @presigned_bucket

    policy = AWS::STS::Policy.new
    policy.allow(:actions => :any, :resource => :any)
    session = AWS::STS.new.new_federated_session("session", :policy => policy)
    s3 = AWS::S3.new(session.credentials)
    @presigned_bucket = s3.buckets[bucket_name]
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