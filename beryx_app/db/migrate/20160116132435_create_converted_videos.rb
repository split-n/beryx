class CreateConvertedVideos < ActiveRecord::Migration
  def change
    create_table :converted_videos do |t|
      t.integer  :video_id, null: false
      t.string :param_class, null: false
      t.text :param_json, null: false
      t.string :converted_file_path, null: false
      t.string :converted_dir_path, null: false
      t.integer :job_status, null: false
      t.string :jid
      t.datetime :last_played, null: false

      t.timestamps null: false
    end

    add_foreign_key "converted_videos", "videos"
  end
end
