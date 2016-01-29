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
  RAILS_PUBLIC_FS_PATH = Rails.root + "public"
  CONVERTED_VIDEOS_FS_PATH = RAILS_PUBLIC_FS_PATH + "converted_videos"
  belongs_to :video
  enum job_status: { building: 0, queued: 1, running: 2, done: 3, fail: 4 }

  class << self
    def convert_to_hls(video, param)
      param = ConvertParams::CopyHls.new
      converted_dir_path =  CONVERTED_VIDEOS_FS_PATH + SecureRandom.hex
      converted_file_path = converted_dir_path + "playlist.m3u8"

      convert_to(video, param, converted_dir_path, converted_file_path)
    end

    def convert_to_copy_fragmented_mp4(video)
      param = ConvertParams::CopyFragmentedMp4.new
      converted_dir_path =  CONVERTED_VIDEOS_FS_PATH + SecureRandom.hex
      converted_file_path = converted_dir_path + "play.mp4"

      convert_to(video, param, converted_dir_path, converted_file_path)
    end

    def convert_to(video, param, converted_dir_path, converted_file_path)
      done_c_video = self.find_by(video: video, param_class: param.class.name, param_json: param.to_json)
      if done_c_video
        if done_c_video.fail?
          done_c_video.destroy
        else
          return done_c_video
        end
      end

      c_video = video.converted_videos.create(
          param_class: param.class.name, param_json: param.to_json,
          converted_dir_path: converted_dir_path,
          converted_file_path: converted_file_path, job_status: :building,
          last_played: Time.now
        )

      jid = VideoConvertWorker.perform_async(c_video.id)
      c_video.job_status = :queued
      c_video.jid = jid
      c_video.save!
      c_video
    end
  end

  def run_convert
    self.job_status = :running
    save!

    FileUtils.mkdir_p(self.converted_dir_path)

    param = Module.const_get(self.param_class).new(JSON.parse(self.param_json))
    command = param.to_command(self.video.path, self.converted_dir_path, self.converted_file_path)

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

  def file_url_path
    self.converted_file_path.gsub(RAILS_PUBLIC_FS_PATH.to_s, "")
  end

  def destroy
    if Dir.exist?(self.converted_dir_path)
      FileUtils.rm_r(self.converted_dir_path)
    end
    super
  end
end
