class AddProviderUrlsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :twitter_url, :string
    add_column :users, :github_url, :string
  end
end
