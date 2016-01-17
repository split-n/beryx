module ConvertParams

  class CopyHls
    class << self
      def from_json(json)
        self.new
      end
    end

    def to_json
      "{}"
    end

    def to_command(source_path, converted_dir_path, converted_file_path)
      %Q(ffmpeg -i "#{source_path}" -acodec copy -vcodec copy -vbsf h264_mp4toannexb -map 0 -f segment -segment_format mpegts -segment_time 5 -segment_list "#{converted_file_path}" -segment_list_flags -cache "#{converted_dir_path}/stream%05d.ts")
    end
  end


  class CopyFastStartMp4
    class << self
      def from_json(json)
        self.new
      end
    end

    def to_json
      "{}"
    end

    def to_command(source_path, converted_dir_path, converted_file_path)
      %Q(ffmpeg -i "#{source_path}" -acodec copy -vcodec copy -movflags faststart -f mp4 #{converted_file_path})
    end
  end

  class CopyFragmentedMp4
    class << self
      def from_json(json)
        self.new
      end
    end

    def to_json
      "{}"
    end

    def to_command(source_path, converted_dir_path, converted_file_path)
      %Q(ffmpeg -i "#{source_path}" -acodec copy -vcodec copy -movflags frag_keyframe+empty_moov -f mp4 #{converted_file_path})
    end
  end

end
