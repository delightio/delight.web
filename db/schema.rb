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

ActiveRecord::Schema.define(:version => 20120509090655) do

  create_table "accounts", :force => true do |t|
    t.string   "name"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.integer  "administrator_id"
  end

  create_table "app_sessions", :force => true do |t|
    t.decimal  "duration"
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
    t.integer  "app_id"
    t.string   "app_user_id"
    t.string   "app_locale"
    t.string   "app_version"
    t.string   "delight_version"
    t.string   "app_build"
    t.integer  "expected_track_count"
    t.integer  "tracks_count",         :default => 0
    t.string   "app_connectivity"
    t.string   "device_hw_version"
    t.string   "device_os_version"
  end

  create_table "apps", :force => true do |t|
    t.string   "name"
    t.string   "token"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "account_id"
  end

  create_table "beta_signups", :force => true do |t|
    t.string   "email"
    t.string   "app_name"
    t.string   "platform"
    t.boolean  "opengl"
    t.boolean  "unity3d"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "favorites", :force => true do |t|
    t.integer  "user_id"
    t.integer  "app_session_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "invitations", :force => true do |t|
    t.integer  "app_id"
    t.integer  "app_session_id"
    t.string   "email"
    t.string   "message"
    t.string   "token"
    t.datetime "token_expiration"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "permissions", :force => true do |t|
    t.integer  "viewer_id"
    t.integer  "app_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "permissions", ["viewer_id"], :name => "index_permissions_on_viewer_id"

  create_table "tracks", :force => true do |t|
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.integer  "app_session_id"
    t.string   "type"
  end

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
  end

  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
