class VideosController < ApplicationController
  before_action :ensure_logged_user
  def index
    q = params[:q]
    if q && q[:file_name_cont_all]
      @ransack = Video.active.ransack(
          q.except(:file_name_cont_all).merge(
              { file_name_cont_all: q[:file_name_cont_all].split("\s") }
          ))
    else
      @ransack = Video.active.ransack(q)
    end

    @videos = @ransack.result
  end

  def show
    @video = Video.find(params[:id])
    @converted_video = ConvertedVideo.convert_to_copy_hls(@video)
  end
end
