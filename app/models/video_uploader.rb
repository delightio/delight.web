class S3Uploader
  def initialize session_id
    @session_id = session_id
    @presigned_bucket = upload_bucket
  end

  private
  UploadBucket = 'delight_upload'
  def upload_bucket
    policy = AWS::STS::Policy.new
    policy.allow(:actions => :any, :resource => :any)
    session = AWS::STS.new.new_federated_session("session#{@session_id}", :policy => policy)
    s3 = AWS::S3.new(session.credentials)
    s3.buckets[UploadBucket]
  end
end

class VideoUploader < S3Uploader
  def filename
    "#{@session_id}.mp4"
  end

  def object
    @presigned_bucket.objects[filename]
  end

  def presigned_write_uri
    object.url_for :write
  end

  def presigned_read_uri
    object.url_for :read
  end
end