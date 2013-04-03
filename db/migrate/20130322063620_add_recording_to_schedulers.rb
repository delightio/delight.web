class AddRecordingToSchedulers < ActiveRecord::Migration
  def change
    add_column :schedulers, :recording, :boolean
    Scheduler.find_each do |s|
      if s.state == 'recording'
        s.start_recording
      else
        s.stop_recording
      end
    end
    remove_column :schedulers, :state
    remove_column :schedulers, :recorded
    remove_column :schedulers, :scheduled
  end
end
