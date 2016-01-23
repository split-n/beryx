class AddDurationColumnToVideos < ActiveRecord::Migration
  def change
    add_column :videos, :duration, :integer, null: false
  end
end
