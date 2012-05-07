class RenameVideosToTracks < ActiveRecord::Migration
  def up
    rename_table :videos, :tracks
    add_column :tracks, :type, :string
    Track.find_each do |track|
      track.update_attribute :type, 'ScreenTrack'
    end
  end

  def down
    remove_column :tracks, :type
    rename_table :tracks, :videos
  end
end
