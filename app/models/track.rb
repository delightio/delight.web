class UniqueTrackValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    other_tracks_type = Track.where(:app_session_id => value).
                          select("type").map &:type
    if (other_tracks_type.include? record.type)
      record.errors[:base] << "App Session #{value} already has uploaded #{record.type}."
    end
  end
end


class Track < ActiveRecord::Base
  include ActiveModel::Validations

  belongs_to :app_session, :counter_cache => true
  validates :app_session_id, :presence => true, :unique_track => true, :on => :create

  after_create { |t| app_session.track_uploaded self }

  def file_extension
    raise 'Track without type has undefined file file_extension'
  end

  def short_type
    return "" if type.nil?
    type.split('::').last.downcase
  end

  def filename
    "session_#{app_session_id}_#{short_type}.#{file_extension}"
  end

  def storage
    @s3 ||= S3Storage.new filename
  end

  def presigned_write_uri
    storage.presigned_write_uri
  end

  def presigned_read_uri
    storage.presigned_read_uri
  end

  def download
    storage.download app_session.working_directory
  end

  def to_json
    {
      url: presigned_read_uri.to_s
    }
  end
end

