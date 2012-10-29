class AppSession < ActiveRecord::Base
  attr_reader :upload_uris

  has_many :properties
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

  include Mixins::Metric

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

    def has_property(key, value)
      joins(:properties).where(:properties => { :key => key, :value => value })
    end

    def has_property_key_or_value(word)
      joins(:properties).where('properties.key = ? or properties.value = ?', word, word)
    end

  end
  extend Scopes

  def private_framework?
    delight_version.split('.').include? 'Private'
  end

  def completed?
    expected_track_count == tracks.count
  end

  def recorded?
    completed? &&
    expected_track_count > 0
  end

  def expected_presentation_track_count
    1
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

  def maximum_frame_rate
    return 20 if private_framework?
    10
  end

  def scale_factor
    case device_hw_version.split(',').first
    when 'iPad3'
      0.25
    else
      0.5
    end
  end

  def average_bit_rate
    return 500000 if private_framework?
    # 1 MB per minute video
    8*1024*1024/60
  end

  def maximum_key_frame_interval
    10.minutes * maximum_frame_rate
  end

  def maximum_duration
    1.hours
  end

  def credits
    1
  end

  # Cost is the actual cost for current app session.
  def cost
    return 0 if duration < 10.seconds
    credits
  end

  def complete
    app.complete_recording cost
  end

  def track_uploaded track
    enqueue_processing if ready_for_processing?
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

  def orientation_track
    OrientationTrack.find_by_app_session_id id
  end

  def event_track
    EventTrack.find_by_app_session_id id
  end

  def view_track
    ViewTrack.find_by_app_session_id id
  end

  def presentation_track
    PresentationTrack.find_by_app_session_id id
  end

  def destroy_presentation_track
    return if presentation_track.nil?

    presentation_track.destroy
  end

  def upload_tracks
    if delight_version.to_f >= 2.4
      return [:screen_track, :touch_track, :orientation_track, :event_track, :view_track]
    else
      return [:screen_track, :touch_track, :orientation_track]
    end
  end

  def working_directory
    if @working_directory.nil?
      working_directory = File.join ENV['WORKING_DIRECTORY'],
                                    self.class.to_s.tableize, id.to_s
      FileUtils.mkdir_p(working_directory) unless Dir.exists? working_directory
      @working_directory = working_directory
    end
    @working_directory
  end

  def update_properties hash
    if hash && !hash.empty?
      hash.each_pair do |k, v|
        #self.properties.first_or_create!({ :key => k, :value => v })
        self.properties.find_or_create_by_key_and_value(k.to_s, v.to_s)
      end
    end
    true
  end

  private
  def generate_upload_uris
    @upload_uris = {}
    count = 0
    if recording?
      upload_tracks.each do |track|
        track_class = track.to_s.camelize.constantize
        @upload_uris.merge!(
          track => track_class.new(app_session_id:id).presigned_write_uri)
      end
      count = 1 + @upload_uris.count # +1 for presentation track
    end
    update_attribute :expected_track_count, count
  end
end
