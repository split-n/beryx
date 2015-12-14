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

ActiveRecord::Schema.define(version: 20151214145118) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "crawl_directories", force: :cascade do |t|
    t.text     "path"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "videos", force: :cascade do |t|
    t.integer  "crawl_directory_id"
    t.text     "path"
    t.text     "file_name"
    t.integer  "file_size"
    t.datetime "deleted_at"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  add_index "videos", ["crawl_directory_id"], name: "index_videos_on_crawl_directory_id", using: :btree

  add_foreign_key "videos", "crawl_directories"
end
