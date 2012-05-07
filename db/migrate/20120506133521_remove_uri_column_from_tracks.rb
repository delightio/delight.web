class RemoveUriColumnFromTracks < ActiveRecord::Migration
  def up
    remove_column :tracks, :uri
  end

  def down
    add_column :tracks, :uri, :string
  end
end
