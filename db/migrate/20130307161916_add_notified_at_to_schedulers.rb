class AddNotifiedAtToSchedulers < ActiveRecord::Migration
  def change
    add_column :schedulers, :notified_at, :datetime

    App.find_each do |app|
      wifi_only = app.settings["uploading_on_wifi_only"]
      recordings = app.settings["recordings"].to_i
      recording_state = app.settings["recording_state"]

      app.scheduler = Scheduler.create app_id: app.id
      app.save
      app.reload

      app.schedule_recordings app.settings["recordings"].to_i
      if wifi_only == "true"
        app.set_uploading_on_wifi_only true
      else
        app.set_uploading_on_wifi_only false
      end
      if recording_state == "recording"
        app.resume_recording
      else
        app.pause_recording
      end
    end

  end
end
