class UsersController < ApplicationController
  before_action :ensure_logged_user
  before_action :set_user

  layout 'application_with_header'

  def show
  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to @user, notice: 'User was successfully updated.'
    else
      render :new
    end
  end

  private
  def set_user
    @user = current_user
  end

  def user_params
    params.require(:user).permit
  end
end
