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

ActiveRecord::Schema.define(version: 20160126065711) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "converted_videos", force: :cascade do |t|
    t.integer  "video_id",            null: false
    t.string   "param_class",         null: false
    t.text     "param_json",          null: false
    t.string   "converted_file_path", null: false
    t.string   "converted_dir_path",  null: false
    t.integer  "job_status",          null: false
    t.string   "jid"
    t.datetime "last_played",         null: false
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

  create_table "crawl_directories", force: :cascade do |t|
    t.text     "path",             null: false
    t.datetime "deleted_at"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.integer  "crawl_job_status", null: false
    t.string   "crawl_jid"
  end

  create_table "existed_video_on_crawls", force: :cascade do |t|
    t.integer  "video_id",           null: false
    t.integer  "crawl_directory_id", null: false
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  add_index "existed_video_on_crawls", ["crawl_directory_id"], name: "index_existed_video_on_crawls_on_crawl_directory_id", using: :btree
  add_index "existed_video_on_crawls", ["video_id"], name: "index_existed_video_on_crawls_on_video_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "login_id",                        null: false
    t.string   "password_digest",                 null: false
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.boolean  "admin",           default: false, null: false
  end

  create_table "videos", force: :cascade do |t|
    t.integer  "crawl_directory_id"
    t.text     "path",                           null: false
    t.text     "file_name",                      null: false
    t.integer  "file_size",            limit: 8, null: false
    t.datetime "deleted_at"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.datetime "file_timestamp",                 null: false
    t.integer  "duration",                       null: false
    t.text     "normalized_file_name",           null: false
  end

  add_index "videos", ["crawl_directory_id"], name: "index_videos_on_crawl_directory_id", using: :btree
  add_index "videos", ["file_timestamp"], name: "index_videos_on_file_timestamp", using: :btree
  add_index "videos", ["path"], name: "index_videos_on_path", unique: true, using: :btree

  add_foreign_key "converted_videos", "videos"
  add_foreign_key "existed_video_on_crawls", "crawl_directories"
  add_foreign_key "existed_video_on_crawls", "videos"
  add_foreign_key "videos", "crawl_directories"
end
