class AddCallbackUrlToAppSessions < ActiveRecord::Migration
  def change
    add_column :app_sessions, :callback_url, :string
  end
end
