class AddNormalizedFileNameColumnToVideos < ActiveRecord::Migration
  def change
    add_column :videos, :normalized_file_name, :text, null: false
  end
end
