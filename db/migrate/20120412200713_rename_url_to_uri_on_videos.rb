class RenameUrlToUriOnVideos < ActiveRecord::Migration
  def up
    rename_column :videos, :url, :uri
  end

  def down
    rename_column :videos, :uri, :url
  end
end
