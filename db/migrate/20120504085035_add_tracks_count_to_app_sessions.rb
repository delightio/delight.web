class AddTracksCountToAppSessions < ActiveRecord::Migration
  def change
    add_column :app_sessions, :tracks_count, :integer, :default => 0

    AppSession.reset_column_information
    AppSession.find_each do |as|
      AppSession.reset_counters as.id, :tracks

      # We didn't previously set expected track count. By setting it
      # to the current track count, we are essentially marking all existing
      # app sessions completed and recorded.
      as.update_attribute :expected_track_count, as.tracks.count
    end
  end
end
