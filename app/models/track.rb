class Track < ActiveRecord::Base

  CACHE_DURATION = 1.hour

  belongs_to :app_session, :counter_cache => true
  validates :app_session_id, :presence => true

  after_create { |t| app_session.complete_upload self }

  def file_extension
    raise 'Track without type has undefined file file_extension'
  end

  def filename
    short_type = type.split('::').last.downcase
    "session_#{app_session_id}_#{short_type}.#{file_extension}"
  end

  def storage
    @s3 ||= S3Storage.new filename
  end

  def presigned_write_uri
    if not presigned_write_uri or sign_write_uri_time <= CACHE_DURATION.ago
      presigned_write_uri = storage.presigned_write_uri
    end
    return presigned_write_uri
  end

  def presigned_read_uri
    if not presigned_read_uri or sign_read_uri_time <= CACHE_DURATION.ago
      presigned_read_uri = storage.presigned_read_uri
    end
    return presigned_read_uri
  end
end
