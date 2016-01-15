require 'rails_helper'

RSpec.describe Video, type: :model do
  describe "new instance" do
    context "without CrawlDirectory" do
      let(:path) { "/exists/foo.mp4" }
      before { allow(File).to receive(:exist?).with(path).and_return(true) }
      context "cd is nil" do
        subject { Video.create(path: path) }
        it { expect(subject.errors[:crawl_directory]).to eq ["can't be blank"] }
        it { expect(subject.errors.messages.length).to eq 1 }
      end

      context "specify invalid cd_id" do
        subject { Video.create(path: path, crawl_directory_id: 4) }
        it { expect(subject.errors[:crawl_directory]).to eq ["can't be blank"] }
        it { expect(subject.errors.messages.length).to eq 1 }
      end
    end

    context "with CrawlDirectory" do
      let(:cd_path) { "/exists/" }
      before { allow(Dir).to receive(:exist?).with(cd_path).and_return(true) }
      let!(:cd) { CrawlDirectory.create(path: cd_path) }

      context "without args" do
        subject{ cd.videos.create }
        it { expect(subject.errors[:path]).to eq ["can't be blank"] }
        it { expect(subject.errors.messages.length).to eq 1 }
      end

      context "with not exist path" do
        let(:path) { "/exists/nil.mp4" }
        before { allow(File).to receive(:exist?).with(path).and_return(false) }
        subject{ cd.videos.create(path: path) }
        it { expect(subject.errors[:path]).to eq ["file not found"] }
        it { expect(subject.errors.messages.length).to eq 1 }
      end

      context "path is relative" do
        let(:path) { "foo.mp4" }
        before { allow(File).to receive(:exist?).with(path).and_return(true) }
        subject{ cd.videos.create(path: path, file_size: 300.megabyte) }
        it { expect(subject.errors[:crawl_directory]).to eq ["crawl directory is not parent of directory"] }
        it { expect(subject.errors.messages.length).to eq 1 }
      end

      context "with exist path" do
        let(:path) { "/exists/foo.mp4" }

        context "without file_size" do
          before {
            allow(File).to receive(:exist?).with(path).and_return(true)
            allow(File).to receive(:size).with(path).and_return(300.megabyte)
          }
          subject{ cd.videos.create(path: path) }
          it { should be_valid }
        end

        context "with file_size" do
          before { allow(File).to receive(:exist?).with(path).and_return(true) }

          context "pass wrong instance" do
            let(:cd) { Object.new }
            subject { Video.create(crawl_directory: cd, path: path, file_size: 300.megabyte) }
            it { expect{subject}.to raise_error(ActiveRecord::AssociationTypeMismatch)}
          end

          context "normal args" do
            subject{ cd.videos.create(path: path, file_size: 300.megabyte) }

            context "correct" do
              it { should be_valid }
            end

            context "CrawlDirectory is deleted" do
              before { cd.mark_as_deleted }
              it { expect(subject.errors[:crawl_directory]).to eq ["crawl directory is not active"] }
              it { expect(subject.errors.messages.length).to eq 1 }
            end

            context "wrong CrawlDirectory" do
              let(:path) { "/usr/exists/foo.mp4"}
              it { expect(subject.errors[:crawl_directory]).to eq ["crawl directory is not parent of directory"] }
              it { expect(subject.errors.messages.length).to eq 1 }
            end

            context "unsupported extension" do
              let(:path) { "/exists/foo.zip" }
              it { expect(subject.errors[:path]).to eq ["extension is not supported"] }
              it { expect(subject.errors.messages.length).to eq 1 }
            end

            context "supported extension uppercase" do
              let(:path) { "/exists/foo.MP4" }
              it { should be_valid }
            end
          end

          context "pass crawl_directory_id" do
            subject{ Video.create(crawl_directory_id: cd.id, path: path, file_size: 300.megabyte) }
            it { should be_valid }
          end
        end
      end
    end
  end

  describe "file is deleted after created" do
    let(:cd) { FG.create(:crawl_directory) }
    let(:video) { FG.create(:video, crawl_directory: cd) }
    subject { allow(File).to receive(:exist?).with(video.path).and_return(false)}
    it { expect{subject}.not_to change{video.valid?}.from(true) }
    it { expect{subject}.to change{video.path_exist?}.from(true).to(false) }
  end

  describe "#mark_as_deleted" do
    let(:cd) { FG.create(:crawl_directory) }
    let(:video) { FG.create(:video, crawl_directory: cd) }
    subject { video.mark_as_deleted }
    context "normal" do
      it { expect{subject}.to change{video.deleted?}.from(false).to(true) }
    end

    context "file is deleted" do
      before { allow(File).to receive(:exist?).with(video.path).and_return(false) }
      it { expect{subject}.to change{video.deleted?}.from(false).to(true) }
    end
  end

  describe "#mark_as_active" do
    let(:cd) { FG.create(:crawl_directory) }
    let(:video) { FG.create(:video, crawl_directory: cd) }
    before { video.mark_as_deleted }
    subject { video.mark_as_active }
    context "normal" do
      it { expect{subject}.to change{video.deleted?}.from(true).to(false) }
    end

    context "file is deleted" do
      before { allow(File).to receive(:exist?).with(video.path).and_return(false) }
      it { expect{subject}.not_to change{video.deleted?}.from(true) }
    end
  end
end
