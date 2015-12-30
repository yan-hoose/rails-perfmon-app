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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20151230100812) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "notes", force: :cascade do |t|
    t.integer  "website_id", null: false
    t.text     "text",       null: false
    t.datetime "time",       null: false
  end

  add_index "notes", ["website_id"], name: "index_notes_on_website_id", using: :btree

  create_table "requests", force: :cascade do |t|
    t.integer  "website_id",                null: false
    t.string   "controller",    limit: 255, null: false
    t.string   "action",        limit: 255, null: false
    t.string   "method",        limit: 255, null: false
    t.string   "format",        limit: 255, null: false
    t.integer  "status",        limit: 2,   null: false
    t.float    "view_runtime",              null: false
    t.float    "db_runtime",                null: false
    t.float    "total_runtime",             null: false
    t.datetime "time",                      null: false
    t.json     "params"
  end

  add_index "requests", ["website_id"], name: "index_requests_on_website_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255, null: false
    t.string   "encrypted_password",     limit: 255, null: false
    t.string   "time_zone",              limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
  end

  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "users_websites", force: :cascade do |t|
    t.integer "user_id",    null: false
    t.integer "website_id", null: false
  end

  add_index "users_websites", ["user_id"], name: "index_users_websites_on_user_id", using: :btree
  add_index "users_websites", ["website_id"], name: "index_users_websites_on_website_id", using: :btree

  create_table "websites", force: :cascade do |t|
    t.string   "name",       limit: 255, null: false
    t.string   "url",        limit: 255
    t.string   "api_key",    limit: 255, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "websites", ["api_key"], name: "index_websites_on_api_key", unique: true, using: :btree

  add_foreign_key "notes", "websites", name: "notes_website_id_fkey"
  add_foreign_key "requests", "websites", name: "requests_website_id_fkey"
  add_foreign_key "users_websites", "users", name: "users_websites_user_id_fkey"
  add_foreign_key "users_websites", "websites", name: "users_websites_website_id_fkey"
end
