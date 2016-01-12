class CrawlVideosJob < ActiveJob::Base
  queue_as :crawl_videos

  def perform(crawl_directory_id)
    crawl_directory = CrawlDirectory.find(crawl_directory_id)
    crawl_directory.crawl_videos_and_create
  end
end
