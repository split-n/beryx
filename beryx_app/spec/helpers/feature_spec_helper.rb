module FeatureSpecHelper
  def log_in_as(user)
    visit login_path
    fill_in "user[login_id]", with: user.login_id
    fill_in "user[password]", with: user.password
    click_on "Login"
  end
end