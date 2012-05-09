class AppSession < ActiveRecord::Base
  attr_reader :upload_uris

  has_many :tracks
  belongs_to :app

  has_many :favorites
  has_many :favorite_users, :through => :favorites, :source => :user, :select => 'DISTINCT users.*'

  validates_presence_of :delight_version
  validates_presence_of :app_id, :app_version, :app_build
  validates_presence_of :app_locale
  # LH 110 We will need to run a migration to pre fill the empty entries
  # validates_presence_of :app_connectivity, :device_hw_version, :device_os_version

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

  def expected_presentation_track_count
    recording? ? 1 : 0
  end

  def ready_for_processing?
    expected_track_count == tracks.count + expected_presentation_track_count
  end

  def recording?
    return false if delight_version.to_i < 2 # LH 110
    app.recording?
  end

  def uploading_on_wifi_only?
    app.uploading_on_wifi_only?
  end

  def complete_upload media
    enqueue_processing if ready_for_processing?
    app.complete_recording if recorded?
  end

  def enqueue_processing
    VideoProcessing.enqueue id
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

  def presentation_track
    PresentationTrack.find_by_app_session_id id
  end

  def working_directory
    if @working_directory.nil?
      working_directory = File.join ENV['WORKING_DIRECTORY'], id.to_s
      FileUtils.mkdir_p(working_directory) unless Dir.exists? working_directory
      @working_directory = working_directory
    end
    @working_directory
  end

  private
  def generate_upload_uris
    @upload_uris = {}
    count = 0
    if recording?
      @upload_uris = {
        screen_track: ScreenTrack.new(app_session_id: id).presigned_write_uri,
        touch_track: TouchTrack.new(app_session_id: id).presigned_write_uri
      }
      count = 1 + @upload_uris.count # +1 for presentation track
    end
    update_attribute :expected_track_count, count
  end
end
