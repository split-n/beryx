class CrawlVideosService
  def initialize(crawl_directory)
    @crawl_directory = crawl_directory
    @logger = Rails.logger
  end

  def crawl_exist_videos_path
    raise if @crawl_directory.invalid?
    raise CrawlDirectory::PathNotFoundError unless @crawl_directory.path_exist?
    return self.to_enum(__method__) unless block_given?

    Find.find(@crawl_directory.path).each do |path|
      yield path if Video.file_supported?(path)
    end
  end

  def enqueue_crawl_videos_and_create
    jid = CrawlVideosWorker.perform_async(id)
    @crawl_directory.crawl_job_status = :queued
    @crawl_directory.crawl_jid = jid
    @crawl_directory.save!
  end

  def crawl_videos_and_create
    @crawl_directory.crawl_job_status = :running
    @crawl_directory.save!

    to_create_paths = []

    crawl_exist_videos_path do |path|
      begin
        same_name_videos = Video.where(file_name: File.basename(path)).to_a
        if same_name_videos.empty? # new video
          to_create_paths.push(path)
        else # already crawled path or same name file found
          video = same_name_videos.select{|v| v.path == path}.first
          if video # already crawled path
            path_size = File.size(path)
            if video.file_size != path_size
              video.reload_stats!
            end

            if video.deleted?
              if video.crawl_directory != @crawl_directory
                video.crawl_directory = @crawl_directory
                video.save!
              end
              video.mark_as_active
              @logger.debug("[CrawlVideos] activated #{path}")
            else
              @logger.debug("[CrawlVideos] exists #{path}")
            end
          else # same name file found
            video = same_name_videos.select{|v|
              (!v.path_exist? || v.deleted?) && v.file_size == File.size(path)
            }.first
            if video # same size and deleted file
              video.path = path
              video.save!
              @logger.debug("[CrawlVideos] move detected #{path}")
            else # create new if another one is not same or active
              to_create_paths.push(path)
            end
          end
        end

      if video
        ExistedVideoOnCrawl.create!(video: video, crawl_directory: @crawl_directory)
      end

      rescue ActiveRecord::RecordInvalid => e
        if video.errors[:path].include? "can't get video duration"
          @logger.warn("[CrawlVideos] can't get duration #{video.path} ")
        else
          raise e
        end
      end
    end

    Parallel.each(to_create_paths, in_threads: 4) do |path|
      ActiveRecord::Base.connection_pool.with_connection do
        begin
          video = @crawl_directory.videos.build(path: path)
          video.save!
          ExistedVideoOnCrawl.create!(video: video, crawl_directory: @crawl_directory)
          @logger.debug("[CrawlVideos] created #{path}")
        rescue ActiveRecord::RecordInvalid => e
          if video.errors[:path].include? "can't get video duration"
            @logger.warn("[CrawlVideos] can't get duration #{video.path} ")
          else
            raise e
          end
        end
      end
    end



    crawled_video_marks = ExistedVideoOnCrawl.where(crawl_directory: @crawl_directory)
    crawled_video_ids = crawled_video_marks.select(:video_id)
    not_crawled_active_videos = @crawl_directory.videos.active.where.not(id: crawled_video_ids)
    not_crawled_active_videos.find_each{|video|
      video.mark_as_deleted
    }


  ensure
    crawled_video_marks&.delete_all

    @crawl_directory.crawl_job_status = :not_running
    @crawl_directory.crawl_jid = nil
    @crawl_directory.save!
  end
end