class VideoPathToUnique < ActiveRecord::Migration
  def change
    add_index :videos, :path, unique: true
  end
end
