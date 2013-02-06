class RenameTrackTagsToEvents < ActiveRecord::Migration
  def change
    rename_table :track_tags, :events
    rename_column :tracks, :track_tags_count, :events_count
  end
end
