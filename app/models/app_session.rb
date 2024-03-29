class AppSession < ActiveRecord::Base
  attr_reader :upload_uris

  has_many :properties
  has_many :tracks
  belongs_to :app

  has_many :event_infos
  has_many :events, :through => :event_infos, uniq: true

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

    def processed_after(last_viewed)
      where("app_sessions.updated_at > ? ", last_viewed)
    end

    def favorited
      joins(:favorites)
    end

    def by_funnel(funnel)
      event_ids = funnel.events.map &:id
      ids = EventInfo.where(:event_id=>event_ids.shift).uniq.pluck(:app_session_id)
      event_ids.each do |eid|
        event_app_session_ids = EventInfo.where(:event_id=>eid).uniq.pluck(:app_session_id)
        ids = (ids & event_app_session_ids)
        break if ids.empty?
      end

      AppSession.where(id: ids)
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
      order('app_sessions.updated_at DESC')
    end

    def has_property(key, value)
      joins(:properties).where(:properties => { :key => key, :value => value })
    end

    def has_property_key_or_value(word)
      joins(:properties).where('properties.key = ? or properties.value = ?', word, word)
    end

  end
  extend Scopes

  def events_with_time
    event_infos.map do |ei|
      { name: ei.event.name, time: ei.time.to_f, properties: ei.properties }
    end
  end

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

  def favorited?
    favorites.count > 0
  end

  def favorited_by
    favorite_users
  end

  def ready_for_processing?
    expected_track_count == tracks.count + processed_tracks.count
  end

  # TODO: Can we use AR to model this instead?
  def scheduler
    Scheduler.find_by_app_id app_id
  end

  def recording?
    return @recording if @recording

    return false if delight_version.to_i < 2 # LH 110
    unless (delight_version.include? '2.3.2')
      return false if app_id == 653 && device_os_version.to_f >= 6.0
    end

    @recording = scheduler.recording?
    @recording
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

  # Volume plan is based on the duration of the app session
  def cost
    duration.to_f
  end

  def complete
    app.complete_recording cost
  end

  def track_uploaded track
    if ready_for_processing?
      enqueue_processing
    end
  end

  def enqueue_processing
    VideoProcessing.enqueue id
  end

  def upload_tracks
    common_tracks = [:screen_track, :touch_track, :orientation_track]
    return common_tracks if delight_version.to_f < 3.0
    common_tracks + [:event_track, :view_track]
  end

  def processed_tracks
    [:presentation_track, :gesture_track]
  end

  # named track
  [ :screen_track, :touch_track, :front_track, :orientation_track,
    :event_track, :view_track,
    :presentation_track, :gesture_track ].each do |named_track|
    define_method(named_track) do
      klass = named_track.to_s.camelize.constantize
      klass.find_by_app_session_id id
    end
  end

  [ :presentation_track, :gesture_track ].each do |named_track|
    define_method("destroy_#{named_track}".to_sym) do
      t = send named_track
      return if t.nil?

      t.destroy
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
      cached_credentials = AmazonCredential.new.get
      upload_tracks.each do |track_name|
        track_class = track_name.to_s.camelize.constantize
        track = track_class.new app_session_id:id
        track.storage.credentials = cached_credentials
        @upload_uris.merge!(
          track_name => track.presigned_write_uri)
      end
      count = processed_tracks.count + @upload_uris.count
    end
    update_attribute :expected_track_count, count
  end
end
