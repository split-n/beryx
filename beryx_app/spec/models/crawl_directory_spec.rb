require 'rails_helper'

RSpec.describe CrawlDirectory, type: :model do
  describe "path" do
    context "single instance test" do
      subject { CrawlDirectory.create(path: path) }

      context "with not existed directory path" do
        before {allow(Dir).to receive(:exist?).and_return(false) }
        let(:path) { "/nowhere/" }
        it { is_expected.not_to be_valid }
      end

      it "is invalid when path is blank" do
        expect(CrawlDirectory.create(path: " ")).not_to be_valid
        expect(CrawlDirectory.create(path: "")).not_to be_valid
        expect(CrawlDirectory.create(path: nil)).not_to be_valid
      end

      context "with existed directory path" do
        before { allow(Dir).to receive(:exist?).and_return(true) }
        let(:path) { "/found/" }
        it { is_expected.to be_valid }

        context "when path isn't ended with slash" do
          let(:path) { "/found" }
          it { is_expected.not_to be_valid }
        end

        context "when path isn't started with slash" do
          let(:path) { "found/" }
          it { is_expected.not_to be_valid }
        end
      end

    end


    context "duplicated, but exists" do
      before do
        allow(Dir).to receive(:exist?).and_return(true)
      end

      it "is invalid when other directory is included" do
        d1 = CrawlDirectory.create(path: "/foo/bar/")
        expect(CrawlDirectory.create(path: "/foo/")).not_to be_valid
      end

      it "is invalid when other directory includes this" do
        d1 = CrawlDirectory.create(path: "/foo/bar/")
        expect(CrawlDirectory.create(path: "/foo/bar/baz/")).not_to be_valid
      end

      it "is invalid when same directory found" do
        d1 = CrawlDirectory.create(path: "/foo/bar/")
        expect(CrawlDirectory.create(path: "/foo/bar/")).not_to be_valid
      end

      # 保存はcase sensitiveで行うが、case insensitiveで重複判定は行う
      it "is invalid when same directory found, case insensitive" do
        d1 = CrawlDirectory.create(path: "/foo/bAR/")
        expect(CrawlDirectory.create(path: "/foO/baR/")).not_to be_valid
      end
    end

    it "stores path as case sensitive" do
      allow(Dir).to receive(:exist?).and_return(true)
      path = "/Foo/bAr"
      cd = CrawlDirectory.create(path: path)
      expect(cd.path).to eq path
    end
  end

end
