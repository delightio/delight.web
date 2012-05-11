class CreateGroupInvitations < ActiveRecord::Migration
  def change
    create_table :group_invitations do |t|
      t.integer :app_id
      t.integer :app_session_id
      t.text :emails
      t.text :message

      t.timestamps
    end
  end
end
