require 'rails_helper'

describe CrawlVideosWorker do
  let!(:cd) { FG.create(:crawl_directory) }
  let!(:cd2) { FG.create(:crawl_directory) }

  describe "#queued?" do
    before {
      CrawlVideosWorker.perform_async(cd.id)
    }
    context "can detect it running" do
      it { expect(CrawlVideosWorker.queued?(cd.id)).to eq true }
    end

    context "can detect it not running" do
      it { expect(CrawlVideosWorker.queued?(cd2.id)).to eq false }
    end
  end

end
