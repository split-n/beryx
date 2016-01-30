module ConvertParams
  class Base
    include ActiveModel::Model
    include ActiveModel::Validations::Callbacks

    def as_json
      super(only: [])
    end

    class << self
      def define_property(*props)
        attr_accessor *props
        define_method("as_json") do
          super(only: props.map(&:to_s))
        end
      end
    end
  end

  class CopyHls < Base
    def to_command(source_path, converted_dir_path, converted_file_path)
      raise if self.invalid?
      %Q(ffmpeg -i "#{source_path}" -acodec copy -vcodec copy -sn -vbsf h264_mp4toannexb -map 0 -f segment -segment_format mpegts -segment_time 5 -segment_list "#{converted_file_path}" -segment_list_flags -cache "#{converted_dir_path}/stream%05d.ts")
    end
  end

  class EncodeAvcAacHls < Base
    include ActiveModel::Validations::Callbacks

    X264_PRESETS = %w(ultrafast superfast veryfast faster fast medium slow slower veryslow placebo)
    X264_TUNES = %w(film animation grain stillimage psnr ssim fastdecode zerolatency)

    define_property :video_kbps, :audio_kbps, :width, :height, :preset, :tune, :he_aac
    validates :video_kbps, presence: true, numericality: { only_integer: true }
    validates :audio_kbps, presence: true, numericality: { only_integer: true }
    validates :height, presence: true, numericality: { only_integer: true }
    validates :preset, presence: true, inclusion: { in: X264_PRESETS }
    validates :tune, inclusion: { in: X264_TUNES }, allow_nil: true

    before_validation do
      @preset ||= "fast"
      true
    end


    def to_command(source_path, converted_dir_path, converted_file_path)
      raise if self.invalid?
      cmd = ""
      cmd << %Q(ffmpeg -i "#{source_path}" -filter:v "scale=trunc(oh*a/2)*2:#{@height}" )
      cmd << %Q( -c:a libfdk_aac )
      if @he_aac
        cmd << %Q( -profile:a aac_he )
      end
      cmd << %Q( -b:a #{@audio_kbps}k -c:v libx264 -preset #{@preset} )
      if @tune
        cmd << %Q( -tune #{@tune} )
      end
      cmd << %Q( -b:v #{@video_kbps}k -sn -flags +loop-global_header -bsf h264_mp4toannexb -map 0 )
      cmd << %Q( -f segment -segment_format mpegts -segment_time 15 -segment_list "#{converted_file_path}" -segment_list_flags -cache "#{converted_dir_path}/stream%05d.ts" )
    end
  end

  class CopyFragmentedMp4 < Base
    def to_command(source_path, converted_dir_path, converted_file_path)
      raise if self.invalid?
      %Q(ffmpeg -i "#{source_path}" -acodec copy -vcodec copy -movflags frag_keyframe+empty_moov -f mp4 #{converted_file_path})
    end
  end
end
