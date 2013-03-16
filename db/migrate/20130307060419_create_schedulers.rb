class CreateSchedulers < ActiveRecord::Migration
  def change
    create_table :schedulers do |t|
      t.integer :app_id
      t.string :state
      t.boolean :wifi_only
      t.integer :scheduled
      t.integer :recorded

      t.timestamps
    end
  end
end
