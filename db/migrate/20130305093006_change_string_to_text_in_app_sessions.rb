class ChangeStringToTextInAppSessions < ActiveRecord::Migration
  def up
    change_column :app_sessions, :callback_payload, :text
  end

  def down
    change_column :app_sessions, :callback_payload, :string
  end
end
