class AddCrawlJobColumnToCrawlDirectory < ActiveRecord::Migration
  def change
    add_column :crawl_directories, :crawl_job_status, :integer, null: false, default: 0
    add_column :crawl_directories, :crawl_jid, :string
  end
end
