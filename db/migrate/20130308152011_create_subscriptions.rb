class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions do |t|
      t.integer :account_id
      t.integer :plan_id
      t.integer :usage, :default => 0

      t.timestamps
    end
  end
end
