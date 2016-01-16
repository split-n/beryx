class VideoConvertWorker
  include Sidekiq::Worker
  sidekiq_options queue: :video_convert,
                  retry: 5

  def perform(converted_video_id)
    tv = ConvertedVideo.find(converted_video_id)
    tv.run_convert
  end

end
