class AppSession < ActiveRecord::Base
  attr_reader :upload_uris

  has_one :video
  belongs_to :app
  validates_presence_of :app_id, :app_version, :delight_version, :locale

  def record?
    true
  end

  def wifi_transmission_only?
    true
  end

  def upload_uris
    { screen: VideoUploader.new(id).presigned_uri }
  end
end
