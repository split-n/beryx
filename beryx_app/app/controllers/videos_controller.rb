class VideosController < ApplicationController
  def index
    @videos = Video.active
  end

  def show
    @video = Video.find(params[:id])
  end
end
