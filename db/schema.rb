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

ActiveRecord::Schema.define(:version => 20120412200713) do

  create_table "accounts", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "app_sessions", :force => true do |t|
    t.decimal  "duration"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.integer  "app_id"
    t.string   "app_user_id"
    t.string   "locale"
    t.string   "app_version"
    t.string   "delight_version"
  end

  create_table "apps", :force => true do |t|
    t.string   "name"
    t.string   "token"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "account_id"
  end

  create_table "videos", :force => true do |t|
    t.string   "uri"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.integer  "app_session_id"
  end

end
