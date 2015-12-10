class CreateCrawlDirectories < ActiveRecord::Migration
  def change
    create_table :crawl_directories do |t|
      t.text :path
      t.timestamp :deleted_at

      t.timestamps null: false
    end
  end
end
