# == Schema Information
#
# Table name: videos
#
#  id                 :integer          not null, primary key
#  crawl_directory_id :integer
#  path               :text             not null
#  file_name          :text             not null
#  file_size          :integer          not null
#  deleted_at         :datetime
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_videos_on_crawl_directory_id  (crawl_directory_id)
#  index_videos_on_path                (path) UNIQUE
#
# Foreign Keys
#
#  fk_rails_b52ccf2fa6  (crawl_directory_id => crawl_directories.id)
#

class Video < ActiveRecord::Base
  include SoftDeletable
  VIDEO_EXTS = %w(.mp4 .mkv) # temp
  belongs_to :crawl_directory
  has_many :transcoded_videos
  validates :crawl_directory, presence: true
  validates :path, presence: true
  validate :path_should_exists, if: -> { path.present? }, on: :create
  validate :path_file_extension, :crawl_directory_should_active, :crawl_directory_should_be_parent, if: -> { path.present? }

  before_save do
    self.file_name = File.basename(path)
    self.file_size ||= File.size(path)
  end

  class << self
    def file_supported?(path)
      File.extname(path).downcase.in?(VIDEO_EXTS)
    end
  end

  def path_exist?
    path.present? && File.exist?(path)
  end

  private
  def path_should_exists
    unless path_exist?
      errors.add(:path, "file not found")
    end
  end

  def path_file_extension
    unless Video.file_supported?(path)
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
