class AddCallbackPayloadToAppSessions < ActiveRecord::Migration
  def change
    add_column :app_sessions, :callback_payload, :string
  end
end
