class CreateTranscodedVideos < ActiveRecord::Migration
  def change
    create_table :transcoded_videos do |t|
      t.integer  "video_id", null: false
      t.text :transcode_params, null: false
      t.string :rand, null: false
      t.integer :job_status, null: false
      t.string :jid
      t.datetime :last_played, null: false

      t.timestamps null: false
    end

    add_index "transcoded_videos", ["video_id"], name: "index_transcoded_videos_on_video_id", using: :btree
    add_foreign_key "transcoded_videos", "videos"
  end
end
