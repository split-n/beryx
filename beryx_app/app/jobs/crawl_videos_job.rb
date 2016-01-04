class CrawlVideosJob < ActiveJob::Base
  queue_as :crawl_videos

  def perform(crawl_directory)
    crawl_directory.crawl_videos_and_create
  end
end
