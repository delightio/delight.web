class RenamePathToUrlInVideos < ActiveRecord::Migration
  def up
    rename_column :videos, :path, :url
  end

  def down
    rename_column :videos, :url, :path
  end
end
