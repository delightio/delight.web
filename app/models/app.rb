class App < ActiveRecord::Base
  belongs_to :account
  has_many :app_sessions

  has_many :permissions
  has_many :viewers, :through => :permissions

  after_create :generate_token
  validate :token, :presence => true, :uniqueness => true

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
    scheduled_recordings > 0 &&
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

  def scheduled_recordings
    settings[:recordings].to_i
  end

  def schedule_recordings n
    settings.incr :recordings, n
  end

  def use_recording
    settings.incr :recordings, -1
    account.use_credits 1
  end

  def uploading_on_wifi_only?
    settings[:uploading_on_wifi_only] != 'false'
  end

  def set_uploading_on_wifi_only flag
    settings[:uploading_on_wifi_only] = flag
  end

  private
  def generate_token
    update_attribute :token, "#{SecureRandom.hex 12}#{id}"
  end

end
