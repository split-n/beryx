class ChangeLoginIdUniqueToUser < ActiveRecord::Migration
  def change
    change_column :users, :login_id, :string, null: false, unique: true
  end
end
