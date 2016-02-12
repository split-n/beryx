class CrawlVideosWorker
  include Sidekiq::Worker
  sidekiq_options queue: :crawl_videos,
                  retry: 1,
                  unique: :while_executing,
                  unique_args: proc{ [] }

  def perform(crawl_directory_id)
    crawl_directory = CrawlDirectory.find(crawl_directory_id)
    cvs = CrawlVideosService.new(crawl_directory)
    cvs.crawl_videos_and_create
  end


end