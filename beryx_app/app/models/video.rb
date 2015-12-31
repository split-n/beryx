class Video < ActiveRecord::Base
  include SoftDeletable
  VIDEO_EXTS = %w(.mp4 .mkv) # temp
  belongs_to :crawl_directory
  validates :crawl_directory, presence: true
  validates :path, presence: true
  validate :path_should_exists, :path_file_extension, :crawl_directory_should_active, :crawl_directory_should_be_parent, if: -> { path.present? }

  before_save do
    self.file_name = File.basename(path)
    self.file_size ||= File.size(path)
  end

  private
  def path_should_exists
    unless path.present? && File.exist?(path)
      errors.add(:path, "file not found")
    end
  end

  def path_file_extension
    ext = File.extname(path)
    unless ext.in?(VIDEO_EXTS)
      errors.add(:path, "extension is not supported")
    end
  end

  def crawl_directory_should_active
    return unless crawl_directory.kind_of? CrawlDirectory
    if crawl_directory.deleted?
      errors.add(:crawl_directory, "crawl directory is not active")
    end
  end

  def crawl_directory_should_be_parent
    return unless crawl_directory.kind_of? CrawlDirectory
    unless path.start_with?(crawl_directory.path)
      errors.add(:crawl_directory, "crawl directory is not parent of directory")
    end
  end
end
