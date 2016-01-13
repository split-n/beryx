class CrawlVideosWorker
  include Sidekiq::Worker
  sidekiq_options queue: :crawl_videos,
                  retry: 5,
                  unique: :while_executing

  class << self
    def status(crawl_directory_id)
      job = get_queued_by_id(crawl_directory_id)
      return :queued if job

      worker = get_running_worker_by_id(crawl_directory_id)
      return :running if worker

      :not_running
    end

    def get_queued_by_id(crawl_directory_id)
      jobs = Sidekiq::Queue.new("crawl_videos")&.map{|x| x.item}
      jobs&.select{|job|
        job["class"] == "CrawlVideosWorker" && job["args"] == [crawl_directory_id]
      }.first
    end

    def get_running_worker_by_id(crawl_directory_id)
      Sidekiq::Workers.new.select{|worker|
        payload = worker[2]["payload"]
        payload["queue"] == "crawl_videos" && payload["args"] == [crawl_directory_id]
      }.first
    end

  end

  def perform(crawl_directory_id)
    sleep 60
    crawl_directory = CrawlDirectory.find(crawl_directory_id)
    crawl_directory.crawl_videos_and_create
  end


end