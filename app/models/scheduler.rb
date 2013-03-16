class Scheduler < ActiveRecord::Base
  attr_accessible :app_id, :recorded, :scheduled, :state, :wifi_only, :notified_at

  belongs_to :app
  validates_presence_of :app_id

  def completed?
    return false if recorded.nil? || scheduled.nil?
    recorded >= scheduled
  end

  def recording?
    state=='recording' && !completed?
  end

  def schedule n
    update_attributes scheduled: n, recorded: 0, notified_at: nil
  end

  # We could actually check data base and see how many have been recorded
  # since we started recording.
  def record n
    previous = recorded || 0
    update_attributes recorded: previous + n

    notify_users if completed?
  end

  def remaining
    left = scheduled - recorded
    (left < 0) ? 0 : left
  end

  def pause
    update_attributes state: 'paused'
  end

  def resume
    update_attributes state: 'recording'
  end

  def wifi_only?
    wifi_only || false
  end

  def set_wifi_only flag
    update_attributes wifi_only: flag
  end

  def notify_users
    return if notified?
    Resque.enqueue ::AppRecordingCompletion, app_id
    update_attributes notified_at: Time.now
  end

  def notified?
    notified_at != nil
  end
end
