class AddAppSessionIdsToVideos < ActiveRecord::Migration
  def change
    add_column :videos, :app_session_id, :integer

  end
end
