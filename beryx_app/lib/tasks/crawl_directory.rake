namespace :crawl_directory do
  task :enqueue_crawl_all => :environment do
    CrawlDirectory.active.each{|cd|
      cvs = CrawlVideosService.new(cd)
      cvs.enqueue_crawl_videos_and_create
    }
  end
end
