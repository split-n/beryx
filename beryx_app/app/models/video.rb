# == Schema Information
#
# Table name: videos
#
#  id                   :integer          not null, primary key
#  crawl_directory_id   :integer
#  path                 :text             not null
#  file_name            :text             not null
#  file_size            :integer          not null
#  deleted_at           :datetime
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  file_timestamp       :datetime         not null
#  duration             :integer          not null
#  normalized_file_name :text             not null
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

require 'open3'

class Video < ActiveRecord::Base
  include SoftDeletable
  include PrivateAttribute
  VIDEO_EXTS = %w(.mp4 .mkv) # temp
  belongs_to :crawl_directory
  has_many :converted_videos, dependent: :destroy
  validates :crawl_directory, presence: true
  validates :path, presence: true
  validate :path_should_exists, if: -> { path.present? }, on: :create
  validate :path_file_extension, :crawl_directory_should_active,
           :crawl_directory_should_be_parent, :duration_should_available, if: -> { path.present? }

  attr_private_writer :file_name, :file_size, :file_timestamp, :duration, :normalized_file_name

  before_create do
    self.file_name = File.basename(path)
    self.file_size = File.size(path)
    self.file_timestamp = File.mtime(path)
    self.duration = get_duration
    self.normalized_file_name = self.class.normalize_file_name(path)
  end

  class << self
    def file_supported?(path)
      File.extname(path).downcase.in?(VIDEO_EXTS)
    end

    def normalize_file_name(file_name)
      file_name.tr("０-９", "0-9").tr("ａ-ｚ", "a-z").tr("Ａ-Ｚ", "a-z").tr("A-Z", "a-z")
    end
  end

  def mark_as_active
    return false unless path_exist?
    super
  end

  def path_exist?
    path.present? && File.exist?(path)
  end

  def mark_as_deleted
    super
    self.converted_videos.clear
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

  def duration_should_available
    return unless path_exist?
    errors.add(:path, "can't get video duration") unless get_duration
  end

  def get_duration
    return self.duration if self.duration
    return  @_duration if @_duration
    cmd = %Q(ffprobe -show_streams -print_format json "#{self.path}" 2>/dev/null)
    out, err, status = Open3.capture3(cmd)
    probe = JSON.parse(out)
    @_duration = probe.dig("streams", 0, "duration")&.to_i
  end
end
