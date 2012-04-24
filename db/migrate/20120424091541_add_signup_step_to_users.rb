class AddSignupStepToUsers < ActiveRecord::Migration
  def change
    add_column :users, :signup_step, :integer, :default => 1
  end
end
