class AddExpectedTrackCountToAppSessions < ActiveRecord::Migration
  def change
    add_column :app_sessions, :expected_track_count, :integer

  end
end
