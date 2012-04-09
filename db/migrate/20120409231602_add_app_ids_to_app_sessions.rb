class AddAppIdsToAppSessions < ActiveRecord::Migration
  def change
    add_column :app_sessions, :app_id, :integer

  end
end
