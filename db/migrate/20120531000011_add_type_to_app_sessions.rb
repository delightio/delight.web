class AddTypeToAppSessions < ActiveRecord::Migration
  def change
    add_column :app_sessions, :type, :string
  end
end
