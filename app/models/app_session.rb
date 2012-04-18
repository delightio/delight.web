class AppSession < ActiveRecord::Base
  attr_reader :upload_uris

  has_one :video
  belongs_to :app
  validates_presence_of :app_id, :app_version, :delight_version, :locale

  def recording?
    app.recording?
  end

  def uploading_on_wifi_only?
    app.uploading_on_wifi_only?
  end

  def upload_uris
    { screen: VideoUploader.new(id).presigned_uri }
  end
end
