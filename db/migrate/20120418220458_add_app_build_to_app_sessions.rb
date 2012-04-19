class AddAppBuildToAppSessions < ActiveRecord::Migration
  def change
    add_column :app_sessions, :app_build, :string
  end
end
