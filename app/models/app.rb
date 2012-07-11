class App < ActiveRecord::Base
  belongs_to :account
  has_many :app_sessions

  has_many :permissions
  has_many :viewers, :through => :permissions, :uniq => true

  has_many :group_invitations
  has_many :invitations

  attr_accessible :name

  after_create :assign_admin_as_viewer
  after_create :generate_token
  after_create :schedule_initial_recording
  validate :token, :presence => true, :uniqueness => true
  validates :name, :presence => true

  include Redis::Objects
  hash_key :settings # recordings to get, paused?, wifi only?

  module Scopes
    def administered_by(user)
      select('DISTINCT apps.*').joins(:account).where(:accounts => { :administrator_id => user.id })
    end

    def viewable_by(user)
      select('DISTINCT apps.*').joins(:permissions).where(:permissions => { :viewer_id => user.id })
    end
  end
  extend Scopes

  def recording?
    !recording_paused? &&
    scheduled_recordings > 0
    # && account.remaining_credits > 0
  end

  def scheduled_recordings
    settings[:recordings].to_i
  end

  def schedule_recordings n
    settings[:recordings] = n
    settings[:scheduled_at] = Time.now.to_i
  end

  def complete_recording
    # We got more recordings than we expected
    if scheduled_recordings <= 0
      handle_extra_recordings
      return
    end

    settings.incr :recordings, -1
    account.use_credits 1
    notify_users
  end

  def handle_extra_recordings
    schedule_recordings 0
    # TODO we probably want to log this
  end

  def resume_recording
    settings[:recording_state] = 'recording'
  end

  def pause_recording
    settings[:recording_state] = 'paused'
  end

  def recording_paused?
    settings[:recording_state] == 'paused'
  end

  def uploading_on_wifi_only?
    settings[:uploading_on_wifi_only] != 'false'
  end

  def set_uploading_on_wifi_only flag
    settings[:uploading_on_wifi_only] = flag
  end

  def administrator
    account.administrator
  end

  def administered_by?(user)
    administrator == user
  end

  def viewable_by?(user)
    self.viewers.include?(user)
  end

  def emails
    (viewers.map &:email).uniq
  end

  def previously_notified?
    settings[:scheduled_at].nil?
  end

  def ready_to_notify?
    !previously_notified? && scheduled_recordings==0
  end

  def notify_users
    if ready_to_notify?
      Resque.enqueue ::AppRecordingCompletion, id
      REDIS.hdel settings.key, :scheduled_at
    end
  end

  def last_viewed_at_by_user(user)
    permission = permissions.where(:viewer_id => user.id).first
    if permission.nil?
      nil
    else
      permission.last_viewed_at
    end
  end

  def log_view(user)
    permission = permissions.where(:viewer_id => user.id).first
    if permission.nil?
      raise "Invalid permission"
    end
    permission.last_viewed_at = Time.now
    permission.save
  end

  private
  def assign_admin_as_viewer
    viewers << administrator
  end

  def generate_token
    update_attribute :token, "#{SecureRandom.hex 12}#{id}"
  end

  def schedule_initial_recording
    schedule_recordings 2 * Account::FreeCredits
    set_uploading_on_wifi_only false
  end

end
