class CreatePlayHistories < ActiveRecord::Migration
  def change
    create_table :play_histories do |t|
      t.references :video, index: true, foreign_key: true, null: false
      t.references :user, index: true, foreign_key: true, null: false
      t.integer :position, null: false

      t.timestamps null: false
    end
  end
end
