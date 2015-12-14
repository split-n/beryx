class CreateVideos < ActiveRecord::Migration
  def change
    create_table :videos do |t|
      t.references :crawl_directory, index: true, foreign_key: true
      t.text :path
      t.text :file_name
      t.integer :file_size
      t.datetime :deleted_at

      t.timestamps null: false
    end
  end
end
