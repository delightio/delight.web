class CreateInvitations < ActiveRecord::Migration
  def change
    create_table :invitations do |t|
      t.integer :app_id
      t.integer :app_session_id
      t.string :email
      t.string :message
      t.string :token
      t.datetime :token_expiration

      t.timestamps
    end
  end
end
