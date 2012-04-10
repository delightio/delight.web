class ChangeAppUserIdFromIntegerToStringOnAppSessions < ActiveRecord::Migration
  def up
    change_column :app_sessions, :app_user_id, :string
  end

  def down
    change_column :app_sessions, :app_user_id, :integer
  end
end
