class CrawlVideosWorker
  include Sidekiq::Worker
  sidekiq_options queue: :crawl_videos,
                  retry: 5,
                  unique: :while_executing

  def perform(crawl_directory_id)
    sleep 60
    crawl_directory = CrawlDirectory.find(crawl_directory_id)
    crawl_directory.crawl_videos_and_create
  end


end