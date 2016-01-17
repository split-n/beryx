class VideosController < ApplicationController
  before_action :ensure_logged_user
  def index
    @videos = Video.active
  end

  def show
    @video = Video.find(params[:id])
    @converted_video = ConvertedVideo.convert_to_copy_fragmented_mp4(@video)
  end
end
