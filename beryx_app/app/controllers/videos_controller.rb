class VideosController < ApplicationController
  before_action :ensure_logged_user
  def index
    @videos = Video.active
  end

  def show
    @video = Video.find(params[:id])
  end
end
