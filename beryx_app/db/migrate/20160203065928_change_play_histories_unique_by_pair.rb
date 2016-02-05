class ChangePlayHistoriesUniqueByPair < ActiveRecord::Migration
  def change
    add_index :play_histories, [:video_id, :user_id], unique: true
  end
end
