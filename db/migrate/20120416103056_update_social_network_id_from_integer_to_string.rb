class UpdateSocialNetworkIdFromIntegerToString < ActiveRecord::Migration
  def up
    change_column :users, :twitter_id, :string 
    change_column :users, :github_id, :string 
  end

  def down
    change_column :users, :twitter_id, :integer 
    change_column :users, :github_id, :integer 
  end
end
