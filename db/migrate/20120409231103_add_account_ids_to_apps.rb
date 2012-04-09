class AddAccountIdsToApps < ActiveRecord::Migration
  def change
    add_column :apps, :account_id, :integer
  end
end
