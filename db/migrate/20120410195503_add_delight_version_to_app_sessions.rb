class AddDelightVersionToAppSessions < ActiveRecord::Migration
  def change
    add_column :app_sessions, :delight_version, :string

  end
end
