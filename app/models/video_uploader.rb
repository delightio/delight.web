class S3Uploader
  attr_reader :session_id, :presigned_bucket

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
  def presigned_uri
    @presigned_bucket.objects["#{@session_id}.mp4"].url_for(:write)
  end
end