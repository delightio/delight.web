class RemoveTrackIdOfEvents < ActiveRecord::Migration
  def up
    remove_column :events, :track_id
  end

  def down
    add_column :events, :track_id, :integer
    add_index :events, :track_id
  end
end
