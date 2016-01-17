class VideoConvertWorker
  include Sidekiq::Worker
  sidekiq_options queue: :video_convert,
                  retry: 5

  def perform(converted_video_id)
    cv = ConvertedVideo.find(converted_video_id)

    # タイミングが悪い場合に備え
    cv.job_status = :queued
    cv.jid = self.jid
    cv.save!

    cv.run_convert
  end

end
