class AddIndicesForSqlJoin < ActiveRecord::Migration
  def up
    add_index :accounts, [:administrator_id], :name => "acct_admin_id"
    add_index :apps, [:account_id], :name => "apps_acct_id"
    add_index :permissions, [:app_id], :name => "perm_app_id"
    add_index :permissions, [:viewer_id], :name => "perm_viewer_id"
    add_index :app_sessions, [:app_id], :name => "as_app_id"
    add_index :app_sessions, [:created_at], :name => "as_created_at"
    add_index :app_sessions, [:duration], :name => "as_duration"
    add_index :favorites, [:app_session_id], :name => "fav_as_id"
    add_index :favorites, [:user_id], :name => "fav_user_id"
    add_index :tracks, [:type, :app_session_id], :name => "tracks_type_as_id"
  end

  def down
    remove_index :accounts, :name => "acct_admin_id"
    remove_index :apps, :name => "apps_acct_id"
    remove_index :permissions, :name => "perm_app_id"
    remove_index :permissions, :name => "perm_viewer_id"
    remove_index :app_sessions, :name => "as_app_id"
    remove_index :app_sessions, :name => "as_created_at"
    remove_index :app_sessions, :name => "as_duration"
    remove_index :favorites, :name => "fav_as_id"
    remove_index :favorites, :name => "fav_user_id"
    remove_index :tracks, :name => "tracks_type_as_id"
  end
end
