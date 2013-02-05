class CreateEventTrackTags < ActiveRecord::Migration
  def change
    create_table :track_tags do |t|
      t.references :track
      t.string :name
      t.timestamps
    end

    add_index :track_tags, :track_id

    add_column :tracks, :track_tags_count, :integer, default: 0
    add_index :tracks, :track_tags_count
  end
end
