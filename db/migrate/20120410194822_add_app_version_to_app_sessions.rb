class AddAppVersionToAppSessions < ActiveRecord::Migration
  def change
    add_column :app_sessions, :app_version, :string

  end
end
