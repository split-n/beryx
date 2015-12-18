class Video < ActiveRecord::Base
  VIDEO_EXTS = %w(mp4 mkv) # temp
  belongs_to :crawl_directory
  validates :crawl_directory, presence: true
  validates :path, presence: true
  validate :path_should_exists

  before_save do
    file_name = File.basename(path)
    file_size = File.size(path)
  end

  private
  def path_should_exists
    unless path.present? && File.exists?(path)
      errors.add(:path, "Path file not found.")
    end
  end

  def path_file_extension
    VIDEO_EXTS.each do |ext|
      unless path.downcase.end_with? ext
        errors.add(:path, "File #{File.extname(path)} is not supported.")
      end
    end
  end
end
