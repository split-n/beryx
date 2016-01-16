# == Schema Information
#
# Table name: converted_videos
#
#  id                  :integer          not null, primary key
#  video_id            :integer          not null
#  param_class         :string           not null
#  param_json          :text             not null
#  converted_file_path :string           not null
#  converted_dir_path  :string           not null
#  job_status          :integer          not null
#  jid                 :string
#  last_played         :datetime         not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
# Foreign Keys
#
#  fk_rails_e38e5798d7  (video_id => videos.id)
#

class ConvertedVideo < ActiveRecord::Base
  CONVERTED_VIDEOS_ROOT_PATH = Rails.root + "public/converted_videos/"
  belongs_to :video
  enum job_status: { building: 0, queued: 1, running: 2, done: 3, fail: 4 }

  class << self
    def convert_to_copy_hls(video)
      param = ConvertParams::CopyHls.new
      converted_dir_path =  CONVERTED_VIDEOS_ROOT_PATH + SecureRandom.hex
      converted_file_path = converted_dir_path + "playlist.m3u8"

      convert_to(video, param, converted_dir_path, converted_file_path)
    end

    def convert_to(video, param, converted_dir_path, converted_file_path)
      done_video = self.find_by(video: video, param_class: param.class.name, param_json: param.to_json)
      return done_video if done_video


      video = video.converted_videos.create(
          param_class: param.class.name, param_json: param.to_json,
          converted_dir_path: converted_dir_path,
          converted_file_path: converted_file_path, job_status: :building
        )

      jid = VideoConvertWorker.perform_async(video.id)
      video.job_status = :queued
      video.jid = jid
      video.save!
      video
    end
  end

  def run_convert
    raise unless self.job_status.queued?
    self.job_status = :running
    save!

    param = Module.const_get(self.param_class).from_json(self.param_json)
    command = param.to_command(self.converted_dir_path, self.converted_file_path)

    logger.info("[ConvertedVideo] video_id=#{self.video_id} convert command: #{command}")
    stdout = `#{command}`

    if $?.success?
      logger.info("[ConvertedVideo] video_id=#{self.video_id} convert succeed")
      self.job_status = :done
    else
      logger.info("[ConvertedVideo] video_id=#{self.video_id} convert failed #{$?}")
      self.job_status = :fail
    end
    logger.debug("[ConvertedVideo] stdout: \n#{stdout})")

    save!
  end

  def destroy
    FileUtils.rm_r(self.converted_dir_path)
    super
  end
end
