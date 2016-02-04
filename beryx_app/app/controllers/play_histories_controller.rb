class PlayHistoriesController < ApplicationController
  before_action :ensure_logged_user
  def show
    play_history = current_user.play_histories.find_by(video_id: params[:id])
    if play_history
      render json: play_history.as_json
    else
      render json: { error: "not found" }, status: 404
    end

  end

  def create
    play_history = PlayHistory.create_or_update(current_user.id, params[:id], params[:position])

    if play_history.valid?
      render json: play_history.as_json
    else
      render json: play_history.as_json, status: 400
    end
  end
end
