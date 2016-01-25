class ChangeFileSizeColumnTypeOnVideos < ActiveRecord::Migration
  def change
    change_column :videos, :file_size, :integer, limit: 8, null: false
  end
end
