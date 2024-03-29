# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130308152011) do

  create_table "accounts", :force => true do |t|
    t.string   "name"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.integer  "administrator_id"
    t.string   "type"
  end

  add_index "accounts", ["administrator_id"], :name => "acct_admin_id"

  create_table "app_sessions", :force => true do |t|
    t.decimal  "duration"
    t.datetime "created_at",                               :null => false
    t.datetime "updated_at",                               :null => false
    t.integer  "app_id"
    t.string   "app_locale"
    t.string   "app_version"
    t.string   "delight_version"
    t.string   "app_build"
    t.integer  "expected_track_count"
    t.integer  "tracks_count",              :default => 0
    t.string   "app_connectivity"
    t.string   "device_hw_version"
    t.string   "device_os_version"
    t.string   "type"
    t.string   "callback_url"
    t.text     "callback_payload"
    t.integer  "event_infos_count",    :default => 0
  end

  add_index "app_sessions", ["app_id"], :name => "as_app_id"
  add_index "app_sessions", ["created_at"], :name => "as_created_at"
  add_index "app_sessions", ["duration"], :name => "as_duration"

  create_table "app_sessions_events", :force => true do |t|
    t.integer  "app_session_id"
    t.integer  "event_id"
    t.integer  "track_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  add_index "app_sessions_events", ["app_session_id", "event_id", "track_id"], :name => "ase_as_event_track_id"

  create_table "apps", :force => true do |t|
    t.string   "name"
    t.string   "token"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "account_id"
    t.string   "type"
  end

  add_index "apps", ["account_id"], :name => "apps_acct_id"

  create_table "beta_signups", :force => true do |t|
    t.string   "email"
    t.string   "app_name"
    t.string   "platform"
    t.boolean  "opengl"
    t.boolean  "unity3d"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "events", :force => true do |t|
    t.string   "name"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
    t.integer  "event_infos_count", :default => 0
    t.integer  "app_id"
  end

  add_index "events", ["app_id"], :name => "index_events_on_app_id"

  create_table "events_funnels", :force => true do |t|
    t.integer  "event_id"
    t.integer  "funnel_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "events_funnels", ["event_id", "funnel_id"], :name => "index_events_funnels_on_event_id_and_funnel_id"

  create_table "favorites", :force => true do |t|
    t.integer  "user_id"
    t.integer  "app_session_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  add_index "favorites", ["app_session_id"], :name => "fav_as_id"
  add_index "favorites", ["user_id"], :name => "fav_user_id"

  create_table "funnels", :force => true do |t|
    t.string   "name"
    t.integer  "app_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "funnels", ["app_id"], :name => "index_funnels_on_app_id"

  create_table "group_invitations", :force => true do |t|
    t.integer  "app_id"
    t.integer  "app_session_id"
    t.text     "emails"
    t.text     "message"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "invitations", :force => true do |t|
    t.integer  "app_id"
    t.integer  "app_session_id"
    t.string   "email"
    t.text     "message"
    t.string   "token"
    t.datetime "token_expiration"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
    t.integer  "group_invitation_id"
  end

  create_table "permissions", :force => true do |t|
    t.integer  "viewer_id"
    t.integer  "app_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.datetime "last_viewed_at"
  end

  add_index "permissions", ["app_id"], :name => "perm_app_id"
  add_index "permissions", ["viewer_id"], :name => "index_permissions_on_viewer_id"
  add_index "permissions", ["viewer_id"], :name => "perm_viewer_id"

  create_table "plans", :force => true do |t|
    t.string   "type"
    t.string   "name"
    t.integer  "price"
    t.integer  "quota"
    t.integer  "duration"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "properties", :force => true do |t|
    t.integer  "app_session_id"
    t.string   "key"
    t.string   "value"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "schedulers", :force => true do |t|
    t.integer  "app_id"
    t.string   "state"
    t.boolean  "wifi_only"
    t.integer  "scheduled"
    t.integer  "recorded"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.datetime "notified_at"
  end

  create_table "subscriptions", :force => true do |t|
    t.integer  "account_id"
    t.integer  "plan_id"
    t.integer  "usage",      :default => 0
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  create_table "tracks", :force => true do |t|
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
    t.integer  "app_session_id"
    t.string   "type"
    t.integer  "events_count",      :default => 0
    t.integer  "event_infos_count", :default => 0
  end

  add_index "tracks", ["events_count"], :name => "index_tracks_on_track_tags_count"
  add_index "tracks", ["type", "app_session_id"], :name => "tracks_type_as_id"

  create_table "users", :force => true do |t|
    t.integer  "account_id"
    t.string   "twitter_id"
    t.string   "github_id"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "type"
    t.string   "nickname"
    t.string   "image_url"
    t.integer  "signup_step",            :default => 1
    t.string   "twitter_url"
    t.string   "github_url"
  end

  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
