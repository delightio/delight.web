class CreatePermissions < ActiveRecord::Migration
  def change
    create_table :permissions do |t|
      t.integer :viewer_id
      t.integer :app_id

      t.timestamps
    end

    add_index :permissions, :viewer_id
  end
end
