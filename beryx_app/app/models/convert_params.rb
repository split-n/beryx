module ConvertParams

  class CopyHls
    class << self
      def from_json
        self.new
      end
    end

    def initialize

    end

    def to_json
      "{}"
    end

    def to_command(converted_dir_path, converted_file_path)
      # todo
    end
  end

end
