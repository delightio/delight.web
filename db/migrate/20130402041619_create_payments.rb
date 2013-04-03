class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.string :stripe_customer_id, :null => false
      t.integer :subscription_id, :null => false

      t.timestamps
    end

    add_index :payments, :stripe_customer_id
    add_index :payments, :subscription_id
  end
end
