class S3Storage

  SESSION_DURATION = 3600 # 1 hour
  SESSION_RENEW_INTERVAL = 50.minutes # a bit earlier than the session expiration

  attr_reader :filename, :bucket_name
  def initialize filename, bucket_name=ENV['S3_UPLOAD_BUCKET']
    @filename = filename
    @bucket_name = bucket_name
  end

  def presigned_bucket
    return $s3_presigned_bucket if $s3_presigned_bucket and $s3_last_session and $s3_last_session >= SESSION_RENEW_INTERVAL.ago

    policy = AWS::STS::Policy.new
    policy.allow(:actions => :any, :resource => :any)
    session = AWS::STS.new.new_federated_session("session", :policy => policy, :duration => SESSION_DURATION)
    s3 = AWS::S3.new(session.credentials)

    $s3_last_session = Time.now
    $s3_presigned_bucket = s3.buckets[@bucket_name]
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

  def download local_directory
    download_file = File.join local_directory, @filename
    File.open(download_file, 'wb') do |file|
      file.write presigned_object.read
    end
    File.new download_file
  end

  def upload local_file
    local_file.pos = 0
    presigned_object.write local_file.read
  end
end
