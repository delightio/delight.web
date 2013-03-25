class AddIndexToTracksSubscriptionsSchedulers < ActiveRecord::Migration
  def change
    add_index :tracks, :app_session_id
    add_index :subscriptions, :account_id
    add_index :schedulers, :app_id
  end
end
