module SessionsHelper
  def login(user)
    reset_session
    session[:user_id] = user.id
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def logged_in?
    current_user.present?
  end

  def admin_user?
    current_user&.admin?
  end

  def logout
    session.delete(:user_id)
    @current_user = nil
  end

  def ensure_admin_user
    redirect_to login_path unless admin_user?
  end

  def ensure_logged_user
    redirect_to login_path unless logged_in?
  end
end
