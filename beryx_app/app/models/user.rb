class User < ActiveRecord::Base
  validates :login_id, presence: true, format: { with: /\A\w{3,20}\z/ }
  validates :password, length: { minimum: 7 }
  has_secure_password
end
