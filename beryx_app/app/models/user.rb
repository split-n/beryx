# == Schema Information
#
# Table name: users
#
#  id              :integer          not null, primary key
#  login_id        :string
#  password_digest :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  admin           :boolean          default(FALSE), not null
#

class User < ActiveRecord::Base
  validates :login_id, presence: true, format: { with: /\A\w{3,20}\z/ }
  validates :password, length: { minimum: 7 }
  has_secure_password
end
