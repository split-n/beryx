class AddIndexToVideos < ActiveRecord::Migration
  def change
    add_index :videos, :file_timestamp
  end
end
