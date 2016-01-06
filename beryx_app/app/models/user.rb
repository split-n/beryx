class User < ActiveRecord::Base
  validates :login_id, presence: true, format: { with: /\A\w{3,20}\z/ }
  has_secure_password
end
