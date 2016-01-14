# == Schema Information
#
# Table name: transcoded_videos
#
#  id               :integer          not null, primary key
#  video_id         :integer          not null
#  transcode_params :text             not null
#  rand             :string           not null
#  job_status       :integer          not null
#  jid              :string
#  last_played      :datetime         not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_transcoded_videos_on_video_id  (video_id)
#
# Foreign Keys
#
#  fk_rails_63252a304e  (video_id => videos.id)
#


require 'json'
require 'securerandom'

class TranscodedVideo < ActiveRecord::Base
  belongs_to :video
  enum job_status: { building: 0, queued: 1, running: 2, done: 3 }

  class << self
    def convert_just_hls(video)
      transcode_params = TranscodeParams::ConvertToHls.new

      return tv if tv.find_by(transcode_params: transcode_params.to_json)

      rand = generate_rand

      tv = video.transcoded_videos.create!(
          transcode_params: "hls_conv", job_status: :building, rand: rand)
      jid = VideoTranscodeWorker.perform_async(tv.id)
      tv.job_status = :queued
      tv.jid = jid
      tv.save!
    end
  end

  def run_transcode
    params = TranscodeParams.from_json(transcode_params)
    dst_path = rand #todo
    command = params.to_command(dst_path)

  end

  private
  def generate_rand
    SecureRandom.hex(64)
  end
end

module TranscodeParams
  def self.from_json(json)
    hash = JSON.parse(json)
    params_class = Module.const_get(hash["class"])
    params_class.from_hash(hash)
  end

  class ConvertToHls

    class << self
      def from_hash(hash)
        self.new
      end
    end

    def initialize(params={})
      @params = params
    end

    def to_command(dst_path)
      # todo ffmpeg command
    end

    def to_json
      {class: self.class.name}
    end
  end
end

