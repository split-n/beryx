require 'rails_helper'

describe CrawlVideosWorker do
  let!(:cd) { FG.create(:crawl_directory) }
  let!(:cd2) { FG.create(:crawl_directory) }

  describe "#queued?" do
    before {
      CrawlVideosWorker.perform_async(cd.id)
    }
  end

end
