class AppSession < ActiveRecord::Base
  attr_reader :upload_uris

  has_one :video
  belongs_to :app

  has_many :favorites
  has_many :favorite_users, :through => :favorites, :source => :user, :select => 'DISTINCT users.*'

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

    def date_between(min, max)  #inclusive
      if min and max
        where('app_sessions.created_at >= ? and app_sessions.created_at <= ?', min, max)
      else
        where('app_sessions.created_at IS NOT NULL')
      end
    end

    def duration_between(min, max) #inclusive
      if min and max
        where('app_sessions.duration >= ? and app_sessions.duration <= ?', min, max)
      else
        where('app_sessions.duration is NOT NULL')
      end
    end

    def recorded
      joins(:video).where('videos.app_session_id is NOT NULL')
    end

    def latest
      order('updated_at DESC')
    end
  end
  extend Scopes

  def recording?
    app.recording?
  end

  def uploading_on_wifi_only?
    app.uploading_on_wifi_only?
  end

  def complete_upload media
    # Normally we will check if we have got all the media types we expect
    # before counting self as a complete recording
    app.complete_recording
  end

  private
  def generate_upload_uris
    @upload_uris = {}
    if recording?
      @upload_uris = { screen: VideoUploader.new(id).presigned_write_uri }
    end
  end
end
