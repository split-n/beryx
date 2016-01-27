# == Schema Information
#
# Table name: crawl_directories
#
#  id               :integer          not null, primary key
#  path             :text             not null
#  deleted_at       :datetime
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  crawl_job_status :integer          not null
#  crawl_jid        :string
#

require 'find'


class CrawlDirectory < ActiveRecord::Base
  class PathNotFoundError < StandardError; end

  enum crawl_job_status: { not_running: 0, queued: 1, running: 2 }

  include SoftDeletable
  attr_readonly :path
  validates :path, presence: true
  validates :path, format: {with: %r{\A/}, message: "must be started with /"}, if: -> { path.present? }
  validates :path, format: {with: %r{/\z}, message: "must be ended with /"}, if: -> { path.present? }
  validate :path_should_exists, if: -> { path.present? }, on: :create
  validate :path_should_not_include_others, :path_should_not_relative, if: -> { path.present? }
  has_many :videos, dependent: :destroy, validate: false

  before_save do
    self.crawl_job_status ||= :not_running
  end

  def can_mark_as_active?
    duplicated_directory.nil?
  end

  def mark_as_deleted(time=Time.current)
    self.videos.active.find_each do |v|
      v.mark_as_deleted(time)
    end
    super(time)
  end

  def mark_as_active
    raise PathNotFoundError unless path_exist?
    deleted_at = self.deleted_at
    succeed = super
    if succeed && deleted_at
      self.videos.deleted.where(deleted_at: deleted_at).find_each do |v|
        v.mark_as_active
      end
    end
    succeed
  end

  def enqueue_crawl_videos_and_create
    jid = CrawlVideosWorker.perform_async(id)
    self.crawl_job_status = :queued
    self.crawl_jid = jid
    save!
  end

  def path_exist?
    path.present? && Dir.exist?(path)
  end

  def crawl_videos_and_create
    self.crawl_job_status = :running
    save!

    crawl_exist_videos_path do |path|
      begin
      same_name_and_size_videos = Video.where(file_name: File.basename(path), file_size: File.size(path))
      if same_name_and_size_videos.empty? # new video
        video = self.videos.build(path: path)
        video.save!
      else # already crawled path or same file found
        video = same_name_and_size_videos.select{|v| v.path == path}.first
        if video # already crawled path
          if video.deleted?
            if video.crawl_directory != self
              video.crawl_directory = self
              video.save!
            end
            video.mark_as_active
            logger.debug("[CrawlVideos] activated #{path}")
          else
            logger.debug("[CrawlVideos] exists #{path}")
          end
        else # same file found
          video = same_name_and_size_videos.select{|v| !v.path_exist? || v.deleted?}.first
          if video # only deleted file
            video.path = path
            video.save!
            logger.debug("[CrawlVideos] move detected #{path}")
          else # create new if another one is active
            video = self.videos.build(path: path)
            video.save!
          end
        end
      end

      ExistedVideoOnCrawl.create!(video: video, crawl_directory: self)
      rescue ActiveRecord::RecordInvalid => e
        if video.errors[:path].include? "can't get video duration"
          logger.warn("[CrawlVideos] can't get duration #{video.path} ")
        else
          raise e
        end
      end
    end


    crawled_video_marks = ExistedVideoOnCrawl.where(crawl_directory: self)
    crawled_video_ids = crawled_video_marks.select(:video_id)
    not_crawled_active_videos = self.videos.active.where.not(id: crawled_video_ids)
    not_crawled_active_videos.find_each{|video|
      video.mark_as_deleted
    }


  ensure
    crawled_video_marks&.delete_all

    self.crawl_job_status = :not_running
    self.crawl_jid = nil
    save!
  end

  private
  def path_should_exists
    unless path_exist?
      errors.add(:path, "directory not found")
    end
  end

  def path_should_not_include_others
    dup = duplicated_directory
    if dup
      errors.add(:path, "duplicated with #{dup.path}")
    end
  end

  def path_should_not_relative
    if errors[:path].empty?
      if (File.absolute_path(path) + "/") != path
        errors.add(:path, "must be relative path")
      end
    end
  end

  def duplicated_directory
    CrawlDirectory.active.reject{|d| d.id == self.id }.select{|d| dir_includes?(d)}.first
  end

  def dir_includes?(d1)
    p1 = d1.path.downcase
    p2 = self.path.downcase
    p1.start_with?(p2) || p2.start_with?(p1)
  end


  def crawl_exist_videos_path
    raise if invalid?
    raise PathNotFoundError unless path_exist?
    return self.to_enum(__method__) unless block_given?

    Find.find(self.path).each do |path|
      yield path if Video.file_supported?(path)
    end

  end
end
