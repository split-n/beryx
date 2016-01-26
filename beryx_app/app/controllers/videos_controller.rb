class VideosController < ApplicationController
  before_action :ensure_logged_user
  def index
    q = params[:q]
    if q && q[:normalized_file_name_cont_all]
      @ransack = Video.active.ransack(
          q.except(:normalized_file_name_cont_all).merge(
              { normalized_file_name_cont_all: q[:normalized_file_name_cont_all].split("\s") }
          ))
    else
      @ransack = Video.active.ransack(q)
    end

    @ransack.sorts = 'file_timestamp desc' if @ransack.sorts.empty?

    @videos = @ransack.result.page(params[:page])
  end

  def show
    @video = Video.find(params[:id])
    @converted_video = ConvertedVideo.convert_to_copy_hls(@video)
  end
end
