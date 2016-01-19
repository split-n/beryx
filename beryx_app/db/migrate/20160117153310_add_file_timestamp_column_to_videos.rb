class AddFileTimestampColumnToVideos < ActiveRecord::Migration
  def change
    add_column :videos, :file_timestamp, :datetime, null: false
  end
end
