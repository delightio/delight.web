class AppSession < ActiveRecord::Base
  attr_reader :upload_uris

  has_one :video
  belongs_to :app

  validates_presence_of :app_id, :app_version, :app_build
  validates_presence_of :delight_version, :locale

  after_create :generate_upload_uris

  module Scopes
    def administered_by(user)
      joins(:app => :account).where(:accounts => { :administrator_id => user.id })
    end

    def viewable_by(user)
      joins(:app => :permissions).where(:permissions => { :viewer_id => user.id })
    end
  end
  extend Scopes

  def recording?
    app.recording?
  end

  def uploading_on_wifi_only?
    app.uploading_on_wifi_only?
  end

  def generate_upload_uris
    @upload_uris = {}
    if recording?
      @upload_uris = { screen: VideoUploader.new(id).presigned_uri }
    end
  end
end
