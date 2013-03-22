class Scheduler < ActiveRecord::Base
  attr_accessible :app_id, :recording, :wifi_only, :notified_at

  belongs_to :app
  validates_presence_of :app_id

  def recording?
    recording == true
  end

  def start_recording
    update_attributes recording: true
  end

  def stop_recording
    update_attributes recording: false
  end

  def wifi_only?
    wifi_only || false
  end

  def set_wifi_only flag
    update_attributes wifi_only: flag
  end

  # TODO: when do we notify users
  def notify_users
    return if notified?
    Resque.enqueue ::AppRecordingCompletion, app_id
    update_attributes notified_at: Time.now
  end

  def notified?
    notified_at != nil
  end
end
