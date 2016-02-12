class UsersController < ApplicationController
  before_action :ensure_logged_user

  layout 'application_with_header'

  def show
    @user = current_user
  end
end
