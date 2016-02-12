class UsersController < ApplicationController
  before_action :ensure_logged_user

  def show
    @user = current_user
  end
end
