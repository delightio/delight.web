class AddGroupInvitationIdToInvitations < ActiveRecord::Migration
  def change
    add_column :invitations, :group_invitation_id, :integer
  end
end
