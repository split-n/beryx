class SetLoginIdAndPasswordHashNotNullToUser < ActiveRecord::Migration
  def change
    change_column :users, :login_id, :string, null: false
    change_column :users, :password_digest, :string, null: false
  end
end
