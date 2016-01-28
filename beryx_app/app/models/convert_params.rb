module ConvertParams

  class CopyHls
    include ActiveModel::Model
    def to_command(source_path, converted_dir_path, converted_file_path)
      raise if self.invalid?
      %Q(ffmpeg -i "#{source_path}" -acodec copy -vcodec copy -sn -vbsf h264_mp4toannexb -map 0 -f segment -segment_format mpegts -segment_time 5 -segment_list "#{converted_file_path}" -segment_list_flags -cache "#{converted_dir_path}/stream%05d.ts")
    end
  end

  class EncodeAvcAacHls
    include ActiveModel::Model

    attr_accessor :video_kbps, :audio_kbps, :width, :height
    validates :video_kbps, presence: true, numericality: { only_integer: true }
    validates :audio_kbps, presence: true, numericality: { only_integer: true }
    validates :height, presence: true, numericality: { only_integer: true }


    def to_command(source_path, converted_dir_path, converted_file_path)
      raise if self.invalid?
      %Q(ffmpeg -i "#{source_path}" -filter:v "scale=trunc(oh*a/2)*2:#{@height}" -c:a libfdk_aac -b:a #{@audio_kbps}k -c:v libx264 -preset fast -b:v #{@video_kbps}k -sn -flags +loop-global_header -bsf h264_mp4toannexb -map 0 -f segment -segment_format mpegts -segment_time 15 -segment_list "#{converted_file_path}" -segment_list_flags -cache "#{converted_dir_path}/stream%05d.ts")
    end
  end

  class CopyFragmentedMp4
    include ActiveModel::Model
    def to_command(source_path, converted_dir_path, converted_file_path)
      raise if self.invalid?
      %Q(ffmpeg -i "#{source_path}" -acodec copy -vcodec copy -movflags frag_keyframe+empty_moov -f mp4 #{converted_file_path})
    end
  end

end
