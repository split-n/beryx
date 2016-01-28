class AddIndexToVideosFileName < ActiveRecord::Migration
  def change
    add_index :videos, :file_name
  end
end
