class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(login_id: params[:user][:login_id])
    if user&.authenticate(params[:user][:password])
      redirect_to "/"
    else
      render 'new'
    end
  end

  def destroy
  end
end
