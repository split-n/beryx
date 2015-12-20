require 'rails_helper'

RSpec.describe Video, type: :model do
  describe "new instance" do
    context "without CrawlDirectory" do
      context "cd is nil" do
        let(:path) { "/exists/foo.mp4" }
        before { allow(Dir).to receive(:exist?).with(path).and_return(true) }
        subject { Video.create(path: path) }
        it { is_expected.not_to be_valid }
      end

      context "specify invalid cd_id" do
        let(:path) { "/exists/foo.mp4" }
        before { allow(Dir).to receive(:exist?).with(path).and_return(true) }
        subject { Video.create(path: path, crawl_directory_id: 4) }
        it { is_expected.not_to be_valid }
      end
    end

    context "with CrawlDirectory" do
      let(:cd_path) { "/exists/" }
      before { allow(Dir).to receive(:exist?).with(cd_path).and_return(true) }
      let!(:cd) { CrawlDirectory.create(path: cd_path) }

      context "without args" do
        subject{ cd.videos.create }
        it { is_expected.not_to be_valid }
      end

      context "with not exist path" do
        let(:path) { "/exists/nil.mp4" }
        before { allow(File).to receive(:exist?).with(path).and_return(false) }
        subject{ cd.videos.create(path: path) }
        it { is_expected.not_to be_valid }
      end

      context "with exist path" do
        let(:path) { "/exists/foo.mp4" }
        context "CrawlDirectory is deleted" do
          before {
            cd.mark_as_deleted
            allow(File).to receive(:exist?).with(path).and_return(true)
            allow(File).to receive(:size).with(path).and_return(350*1024**2)
          }
          subject{ cd.videos.create(path: path) }
          it { is_expected.not_to be_valid }
        end

        context "without file_size" do
          before {
            allow(File).to receive(:exist?).with(path).and_return(true)
            allow(File).to receive(:size).with(path).and_return(350*1024**2)
          }
          subject{ cd.videos.create(path: path) }
          it { is_expected.to be_valid }
        end

        context "with file_size" do
          before {
            allow(File).to receive(:exist?).with(path).and_return(true)
          }
          subject{ cd.videos.create(path: path, file_size: 350*1024**2) }
          it { is_expected.to be_valid }
        end
      end
    end
  end
end
