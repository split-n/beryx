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
  end

  def convert
    begin
      data = JSON.parse(request.body.read)
    rescue
      render json: {error: "request body is invalid"}, status: 400
      return
    end

    video_id = params[:id]
    video = Video.find_by(id: video_id)
    if video.nil?
      render json: {error: "video_id is invalid"}, status: 400
      return
    end

    case data["convert_method"]
      when "HLS_COPY"
        converted_video = ConvertedVideo.convert_to_copy_hls(video)
      when "HLS_AVC_AAC_ENCODE"
        converted_video = ConvertedVideo.convert_to_encode_avc_aac_hls(video, data["convert_params"])
      else
        render json: {error: "convert_method is invalid"}, status: 400
        return
    end

    if converted_video.invalid?
      render json: {error: "convert_params is invalid"}, status: 400
      return
    end

    response = {
      video_source_path: converted_video.file_url_path
    }
    render json: response
  end
end
