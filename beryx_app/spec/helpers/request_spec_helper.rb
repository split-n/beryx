module RequestSpecHelper
  def log_in_as(user)
    post login_path, { "user[login_id]" =>  user.login_id, "user[password]" =>  user.password }
  end
end