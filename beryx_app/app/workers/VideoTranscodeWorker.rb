class VideoTranscodeWorker
  include Sidekiq::Worker
  sidekiq_options queue: :video_transcode,
                  retry: 5,

  def perform(transcode_video_id)
    tv = TranscodedVideo.find(transcode_video_id)
    tv.run_transcode
  end


end
