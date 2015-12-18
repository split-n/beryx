class VideoFieldsToNotNull < ActiveRecord::Migration
  def change
    change_column :videos, :path, :text, null: false
    change_column :videos, :file_name, :text, null: false
    change_column :videos, :file_size, :integer, null: false
  end
end
