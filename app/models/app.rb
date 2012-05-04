class App < ActiveRecord::Base
  belongs_to :account
  has_many :app_sessions

  has_many :permissions
  has_many :viewers, :through => :permissions

  has_many :invitations

  attr_accessible :name

  after_create :generate_token
  after_create :schedule_initial_recording
  validate :token, :presence => true, :uniqueness => true
  validates :name, :presence => true

  include Redis::Objects
  hash_key :settings # recordings to get, paused?, wifi only?

  module Scopes
    def administered_by(user)
      joins(:account).where(:accounts => { :administrator_id => user.id })
    end

    def viewable_by(user)
      joins(:permissions).where(:permissions => { :viewer_id => user.id })
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
    settings.incr :recordings, -1
    account.use_credits 1
    notify_users
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
    [administrator, *viewers].map &:email
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

  private
  def generate_token
    update_attribute :token, "#{SecureRandom.hex 12}#{id}"
  end

  def schedule_initial_recording
    schedule_recordings Account::FreeCredits
  end

end
