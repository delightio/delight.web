class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.integer :account_id
      t.integer :twitter_id
      t.integer :github_id

      t.timestamps
    end
  end
end
