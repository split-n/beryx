class CrawlDirectoryPathToNotNull < ActiveRecord::Migration
  def change
    change_column :crawl_directories, :path, :text, null: false
  end
end
