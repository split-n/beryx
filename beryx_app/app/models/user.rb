# == Schema Information
#
# Table name: users
#
#  id              :integer          not null, primary key
#  login_id        :string           not null
#  password_digest :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  admin           :boolean          default(FALSE), not null
#

class User < ActiveRecord::Base
  validates :login_id, presence: true, format: { with: /\A\w{3,20}\z/ }
  validates :password, length: { minimum: 7 }
  has_secure_password
end
