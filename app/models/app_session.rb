class AppSession < ActiveRecord::Base
  attr_reader :upload_uris

  has_many :tracks
  belongs_to :app

  has_many :favorites
  has_many :favorite_users, :through => :favorites, :source => :user, :select => 'DISTINCT users.*'

  validates_presence_of :delight_version
  validates_presence_of :app_id, :app_version, :app_build
  validates_presence_of :app_locale, :app_connectivity
  validates_presence_of :device_hw_version, :device_os_version

  after_create :generate_upload_uris

  module Scopes
    def favorite_of(user)
      joins(:favorites).where(:favorites => {:user_id => user.id})
    end

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
      completed.where('app_sessions.expected_track_count > 0')
    end

    def completed
      where('app_sessions.expected_track_count = app_sessions.tracks_count')
    end

    def latest
      order('updated_at DESC')
    end
  end
  extend Scopes

  def completed?
    expected_track_count == tracks.count
  end

  def recorded?
    completed? &&
    expected_track_count > 0
  end

  def recording?
    app.recording?
  end

  def uploading_on_wifi_only?
    app.uploading_on_wifi_only?
  end

  def complete_upload media
    app.complete_recording if completed?
  end

  def screen_track
    ScreenTrack.find_by_app_session_id id
  end

  def touch_track
    TouchTrack.find_by_app_session_id id
  end

  def front_track
    FrontTrack.find_by_app_session_id id
  end

  private
  def generate_upload_uris
    @upload_uris = {}
    if recording?
      @upload_uris = {
        screen_track: ScreenTrack.new(app_session_id: id).presigned_write_uri,
        touch_track: TouchTrack.new(app_session_id: id).presigned_write_uri
      }
    end
    update_attribute :expected_track_count, @upload_uris.count
  end
end
