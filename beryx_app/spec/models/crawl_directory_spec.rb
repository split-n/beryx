require 'rails_helper'

RSpec.describe CrawlDirectory, type: :model do
  describe "create new instance" do
    context "single instance test" do
      subject { CrawlDirectory.create(path: path) }

      context "with not existed directory path" do
        let(:path) { "/etc/" }
        before { allow(Dir).to receive(:exist?).with(path).and_return(false) }
        it { expect(subject.errors[:path]).to eq ["directory not found"] }
      end

      context "path is blank" do
        context "space" do
          let(:path) { " " }
          it { expect(subject.errors[:path]).to eq ["can't be blank"] }
        end
        context "empty" do
          let(:path) { "" }
          it { expect(subject.errors[:path]).to eq ["can't be blank"] }
        end
        context "nil" do
          let(:path) { nil }
          it { expect(subject.errors[:path]).to eq ["can't be blank"] }
        end
      end

      context "with existed directory path" do
        before { allow(Dir).to receive(:exist?).with(path).and_return(true) }
        context "when valid path" do
          let(:path) { "/found/" }
          it { should be_valid }
          it { expect{subject}.to change{CrawlDirectory.active.count}.from(0).to(1) }
        end

        context "when path isn't ended with slash" do
          let(:path) { "/found" }
          it { expect(subject.errors[:path]).to eq ["must be ended with /"] }
        end

        context "when path isn't started with slash" do
          let(:path) { "found/" }
          it { expect(subject.errors[:path]).to eq ["must be started with /"] }
        end

        context "when path contains relative" do
          let(:path) { "/found/../etc/" }
          it { expect(subject.errors[:path]).to eq ["must be relative path"] }
        end
      end

    end


    context "both exists" do
      before do
        allow(Dir).to receive(:exist?).with(path1).and_return(true)
        allow(Dir).to receive(:exist?).with(path2).and_return(true)
      end

      let(:path1) { "/foo/bar/" }
      let!(:cd1) { CrawlDirectory.create(path: path1) }

      subject { CrawlDirectory.create(path: path2) }

      context "when other directory is included" do
        let(:path2) { "/foo/" }
        it { expect(subject.errors[:path]).to eq ["duplicated with #{path1}"] }
      end

      context "when other directory includes this" do
        let(:path2) { "/foo/bar/baz/" }
        it { expect(subject.errors[:path]).to eq ["duplicated with #{path1}"] }
      end

      context "when same directory exists" do
        let(:path2) { "/foo/bar/" }
        it { expect(subject.errors[:path]).to eq ["duplicated with #{path1}"] }
      end

      # 保存はcase sensitiveで行うが、case insensitiveで重複判定は行う
      context "when same directory found, case insensitive" do
        let(:path2) { "/foO/baR/" }
        it { expect(subject.errors[:path]).to eq ["duplicated with #{path1}"] }
      end

      context "when differ" do
        let(:path2) { "/foo/baz/" }
        it{ should be_valid }
        it { expect{subject}.to change{CrawlDirectory.active.count}.by(1) }
      end

      context "when differ 2" do
        let(:path2) { "/gat/bar/" }
        it{ should be_valid }
        it { expect{subject}.to change{CrawlDirectory.active.count}.by(1) }
      end

      context "when one is deleted" do
        before { cd1.mark_as_deleted }
        context "and same path" do
          let(:path2) { "/foo/bar/" }
          it { should be_valid }
          it { expect{subject}.to change{CrawlDirectory.active.count}.by(1) }
        end

        context "and other directory is included" do
          let(:path2) { "/foo/" }
          it { should be_valid }
          it { expect{subject}.to change{CrawlDirectory.active.count}.by(1) }
        end
      end

    end

    it "stores path as case sensitive" do
      path = "/Foo/bAr"
      allow(Dir).to receive(:exist?).with(path).and_return(true)
      cd = CrawlDirectory.create(path: path)
      expect(cd.path).to eq path
    end
  end

  describe "#mark_as_deleted" do
    let(:cd) { FG.create(:crawl_directory) }
    subject { cd.mark_as_deleted }

    context "No videos" do
        it { expect{subject}.not_to change{cd.valid?}.from(true) }
        it { expect{subject}.to change{cd.deleted_at}.from(nil).to(be_within(1.minutes).of(Time.current)) }
        it { expect{subject}.to change{cd.deleted?}.from(false).to(true) }
        it { expect{subject}.to change{CrawlDirectory.deleted.count}.by(1) }
    end

    context "With videos" do
      let(:video_path) { "#{cd.path}abc.mp4" }
      let!(:belong_video) { FG.create(:video, path: video_path, crawl_directory: cd) }
      let!(:cd2) { FG.create(:crawl_directory) }
      let!(:not_belong_video) {
        video_path2 = "#{cd2.path}foo.mp4"
        allow(File).to receive(:exist?).with(video_path2).and_return(true)
        FG.create(:video, path: video_path2, crawl_directory: cd2)
      }
      it { expect{subject}.to change{belong_video.reload.deleted?}.from(false).to(true) }
      it { expect{subject}.not_to change{not_belong_video.reload.deleted?}.from(false) }
      it { expect{subject}.to change{Video.active.count}.from(2).to(1) }
      it { expect{subject}.to change{Video.deleted.count}.from(0).to(1) }
    end
  end

  describe "#mark_as_active" do
    context "only one directory" do
      let(:cd) { FG.create(:crawl_directory) }
      context "without video" do
        subject {
          cd.mark_as_deleted
          cd.mark_as_active
        }
        it { should eq true }
        it { expect{subject}.not_to change{cd.valid?}.from(true) }
      end

      context "with video" do
        let(:video_path) { "#{cd.path}abc.mp4" }
        let!(:belong_video) { FG.create(:video, path: video_path, crawl_directory: cd) }
        context "normal" do
          subject {
            cd.mark_as_deleted
            cd.mark_as_active
          }
          it { expect{subject}.not_to change{belong_video.reload.deleted?}.from(false) }
        end

        context "video is deleted after mark_as_deleted" do
          subject {
            cd.mark_as_deleted
            allow(File).to receive(:exist?).with(video_path).and_return(false)
            cd.mark_as_active
          }
          it { expect{subject}.to change{belong_video.reload.deleted?}.from(false).to(true) }
          it { expect(belong_video).not_to receive(:mark_as_active) }
        end
      end

      context "path is deleted" do
        before {
          cd.mark_as_deleted
        }
        subject {
          allow(Dir).to receive(:exist?).with(cd.path).and_return(false)
          cd.mark_as_active
        }
        it { expect{subject}.to raise_error(CrawlDirectory::PathNotFoundError)  }
        it { expect{subject rescue nil}.not_to change{cd.deleted?}.from(true) }
      end
    end

    context "2 directories" do
      describe "differ directories" do
        it "can make active" do
          cd1 = FG.create(:crawl_directory)
          cd1.mark_as_deleted
          expect(cd1.deleted?).to eq true

          FG.create(:crawl_directory)
          expect(cd1.mark_as_active).to eq true
          expect(CrawlDirectory.active.count).to eq 2
          expect(CrawlDirectory.deleted.count).to eq 0
        end

      end
      describe "dup directory active" do
        let(:path1) { "/valid/" }
        let(:path2) { "/valid/yo/" }
        it "can't make active" do
          cd1 = FG.create(:crawl_directory, path: path1)
          cd1.mark_as_deleted
          expect(cd1.deleted?).to eq true

          cd2 = FG.create(:crawl_directory, path: path2)
          expect(cd2).to be_valid
          expect(cd1.mark_as_active).to eq false
          expect(CrawlDirectory.active.count).to eq 1
          expect(CrawlDirectory.deleted.count).to eq 1
        end
      end
    end
  end

  context "directory is removed after created" do
    let(:cd) { FG.create(:crawl_directory) }
    subject { allow(Dir).to receive(:exist?).with(cd.path).and_return(false) }
    it("still valid") { expect{subject}.not_to change{cd.valid?}.from(true) }
    it("not exist") { expect{subject}.to change{cd.path_exist?}.from(true).to(false) }
  end

  describe "ignores changing path" do
    let(:cd) { FG.create(:crawl_directory) }
    let(:cd_path) { cd.path }
    let(:changed_path) { "/changed/foo/" }
    subject {
      cd.path = changed_path
      cd.save!
    }

    it { expect{subject}.not_to change{cd.reload.path}.from(cd_path) }
  end
end
