class CreatePlans < ActiveRecord::Migration
  def change
    create_table :plans do |t|
      t.string :type
      t.string :name
      t.integer :price
      t.integer :quota
      t.integer :duration

      t.timestamps
    end
  end
end
