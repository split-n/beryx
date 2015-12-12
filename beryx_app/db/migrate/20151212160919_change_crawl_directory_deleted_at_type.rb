class ChangeCrawlDirectoryDeletedAtType < ActiveRecord::Migration
  def change
    change_column :crawl_directories, :deleted_at, :datetime
  end
end
