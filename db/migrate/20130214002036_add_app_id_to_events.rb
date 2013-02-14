class AddAppIdToEvents < ActiveRecord::Migration
  def change
    add_column :events, :app_id, :integer
    add_index :events, :app_id
  end
end
