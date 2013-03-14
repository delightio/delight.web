class S3Storage

  attr_reader :filename, :bucket_name
  def initialize filename, bucket_name=ENV['S3_UPLOAD_BUCKET']
    @filename = filename
    @bucket_name = bucket_name
  end

  def presigned_bucket
    credential = AmazonCredential.new.get
    s3 = AWS::S3.new credential
    s3.buckets[@bucket_name]
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
    start = Time.now
    download_file = File.join local_directory, @filename
    File.open(download_file, 'wb') do |file|
      file.write presigned_object.read
    end
    puts "#{@filename} was downloaded to #{local_directory} in #{Time.now-start} s."

    File.new download_file
  end

  def upload local_file
    start = Time.now
    local_file.pos = 0
    presigned_object.write local_file.read
    puts "#{local_file} was uploaded to S3:#{@bucket_name}/#{@filename} in #{Time.now-start} s."
  end

  def exists?
    presigned_object.exists? && presigned_object.content_length > 0
  end
end