class CreateExistedVideoOnCrawls < ActiveRecord::Migration
  def change
    create_table :existed_video_on_crawls do |t|
      t.references :video, index: true, foreign_key: true, null: false
      t.references :crawl_directory, index: true, foreign_key: true, null: false

      t.timestamps null: false
    end
  end
end
