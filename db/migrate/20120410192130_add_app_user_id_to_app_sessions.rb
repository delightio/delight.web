class AddAppUserIdToAppSessions < ActiveRecord::Migration
  def change
    add_column :app_sessions, :app_user_id, :integer

  end
end
