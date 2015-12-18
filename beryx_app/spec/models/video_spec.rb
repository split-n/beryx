require 'rails_helper'

RSpec.describe Video, type: :model do
  let(:cd_path) { "/exists/" }
  before { allow(Dir).to receive(:exist?).with(cd_path).and_return(true) }
  let!(:cd) { CrawlDirectory.create(path: cd_path) }
  describe "new instance" do
    context "without args" do
      subject{ cd.videos.create }
      it { is_expected.not_to be_valid }
    end
  end
end
