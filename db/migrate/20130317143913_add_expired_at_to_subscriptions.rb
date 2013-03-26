class AddExpiredAtToSubscriptions < ActiveRecord::Migration
  def change
    add_column :subscriptions, :expired_at, :datetime
  end
end
