class CreateProperties < ActiveRecord::Migration
  def change
    create_table :properties do |t|
      t.integer :app_session_id
      t.string :key
      t.string :value

      t.timestamps
    end
  end
end
