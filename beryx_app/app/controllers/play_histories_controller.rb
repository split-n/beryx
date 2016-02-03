class PlayHistoriesController < ApplicationController
  before_action :ensure_logged_user
  def show
    play_histories = current_user.play_histories.where(video_id: params[:id]).order(created_at: :desc)

  end

  def create
    play_history = PlayHistory.destroy_and_create(current_user.id, params[:id], params[:position])

    if play_history.valid?
      render json: play_history.as_json
    else
      render json: play_history.as_json, status: 400
    end
  end
end
