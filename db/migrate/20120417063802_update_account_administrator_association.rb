class UpdateAccountAdministratorAssociation < ActiveRecord::Migration
  def up
    add_column :accounts, :administrator_id, :integer 
  end

  def down
    remove_column :accounts, :administrator_id 
  end
end
