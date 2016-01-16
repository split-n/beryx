class DropTableTranscodedVideos < ActiveRecord::Migration
  def change
    drop_table :transcoded_videos
  end
end
