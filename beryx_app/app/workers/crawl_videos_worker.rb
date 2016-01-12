class CrawlVideosWorker
  include Sidekiq::Worker
  sidekiq_options queue: :crawl_videos,
                  retry: 5,
                  unique: :while_executing

  class << self
    def queued?(crawl_directory_id)
      Sidekiq::Queue.new("crawl_videos")&.select{|job|
        job.item["class"] == "CrawlVideosWorker" && job.item["args"] == [crawl_directory_id]
      }.present?
    end

  end

  def perform(crawl_directory_id)
    crawl_directory = CrawlDirectory.find(crawl_directory_id)
    crawl_directory.crawl_videos_and_create
  end


end