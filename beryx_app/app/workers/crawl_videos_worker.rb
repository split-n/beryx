class CrawlVideosWorker
  include Sidekiq::Worker
  sidekiq_options queue: :crawl_videos,
                  retry: 5,
                  unique: :while_executing

  class << self
    def queued?(crawl_directory_id)
      jobs = if CrawlVideosWorker.respond_to?(:jobs) # on testing
        CrawlVideosWorker.jobs
      else
        Sidekiq::Queue.new("crawl_videos")&.map{|x| x.item}
      end
      jobs&.select{|job|
        job["class"] == "CrawlVideosWorker" && job["args"] == [crawl_directory_id]
      }.present?
    end

  end

  def perform(crawl_directory_id)
    crawl_directory = CrawlDirectory.find(crawl_directory_id)
    crawl_directory.crawl_videos_and_create
  end


end