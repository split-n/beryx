require 'rails_helper'

RSpec.describe ConvertedVideo, type: :model do
  let!(:cd) { FG.create(:crawl_directory) }
  let!(:video) { FG.create(:video, crawl_directory: cd) }
  describe ".convert_to_copy_hls" do
    it "works" do

    end
  end
end
