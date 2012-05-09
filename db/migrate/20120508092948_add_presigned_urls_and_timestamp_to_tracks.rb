class AddPresignedUrlsAndTimestampToTracks < ActiveRecord::Migration
  def change
    add_column :tracks, :presigned_read_uri, :string
    add_column :tracks, :presigned_write_uri, :string
    add_column :tracks, :sign_read_uri_time, :datetime
    add_column :tracks, :sign_write_uri_time, :datetime
  end
end
