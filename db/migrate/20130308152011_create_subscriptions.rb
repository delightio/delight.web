class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions do |t|
      t.integer :account_id
      t.integer :plan_id
      t.integer :usage, :default => 0

      t.timestamps
    end

    # add credit back
    c=0
    Account.find_each do |acc|
      acc.add_credits 60
      c +=1
      puts "done adding #{c} accounts" if c%10==0
    end

    # set unlimited recording
    unlimited_account_ids = [94,386,453,597,651]
    unlimited_account_ids.each do |id|
      acc = Account.find_by_id id
      next if acc.nil?
      acc.subscribe 'unlimited'
    end
  end
end
