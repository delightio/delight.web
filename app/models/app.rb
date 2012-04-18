class App < ActiveRecord::Base
  belongs_to :account
  has_many :app_sessions

  has_many :permissions
  has_many :viewers, :through => :permissions

  before_validation :generate_token, :on => :create
  validate :token, :presence => true, :uniqueness => true

  include Redis::Objects
  hash_key :settings # recordings to get, paused?, wifi only?
  after_create :set_default_recording_settings

  module Scopes
    def administered_by(user)
      joins(:account).where(:accounts => { :administrator_id => user.id })
    end

    def viewable_by(user)
      joins(:permissions).where(:permissions => { :viewer_id => user.id })
    end
  end
  extend Scopes

  def generate_token
    self.token = "#{SecureRandom.hex 12}#{id}"
  end

  def set_default_recording_settings
    resume_recording
    add_recordings 10
    set_uploading_on_wifi_only true
  end

  def recording?
    !recording_paused? &&
    remaining_recordings > 0 &&
    account.remaining_credits > 0
  end

  def recording_paused?
    settings[:recording_state] == 'paused'
  end

  def pause_recording
    settings[:recording_state] = 'paused'
  end

  def resume_recording
    settings[:recording_state] = 'recording'
  end

  def remaining_recordings
    settings[:recordings].to_i
  end

  def add_recordings n
    settings.incr :recordings, n
  end

  def use_recordings n
    add_recordings -1 * n
  end

  def uploading_on_wifi_only?
    settings[:uploading_on_wifi_only] != 'false'
  end

  def set_uploading_on_wifi_only flag
    settings[:uploading_on_wifi_only] = flag
  end
end
