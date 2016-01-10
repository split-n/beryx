class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(login_id: params[:user][:login_id])
    if user&.authenticate(params[:user][:password])
      login(user)
      redirect_to root_path
    else
      render 'new'
    end
  end

  def destroy
    logout
    redirect_to login_path
  end
end
