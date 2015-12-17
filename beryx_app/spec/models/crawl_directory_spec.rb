require 'rails_helper'

RSpec.describe CrawlDirectory, type: :model do
  describe "path" do
    context "single instance test" do
      subject { CrawlDirectory.create(path: path) }

      context "with not existed directory path" do
        before {allow(Dir).to receive(:exist?).and_return(false) }
        let(:path) { "/etc/" }
        it { is_expected.not_to be_valid }
      end

      context "path is blank" do
        context "space" do
          let(:path) { " " }
          it { is_expected.not_to be_valid }
        end
        context "empty" do
          let(:path) { "" }
          it { is_expected.not_to be_valid }
        end
        context "nil" do
          let(:path) { nil }
          it { is_expected.not_to be_valid }
        end
      end

      context "with existed directory path" do
        before { allow(Dir).to receive(:exist?).and_return(true) }
        context "when valid path" do
          let(:path) { "/found/" }
          it { is_expected.to be_valid }
          it "count correct" do
            subject
            expect(CrawlDirectory.count).to eq 1
          end
        end

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


    context "both exists" do
      before do
        allow(Dir).to receive(:exist?).and_return(true)
      end

      subject { CrawlDirectory.create(path: path) }

      let!(:cd1) { CrawlDirectory.create(path: "/foo/bar/") }

      context "when other directory is included" do
        let(:path) { "/foo/" }
        it{ is_expected.not_to be_valid}
      end

      context "when other directory includes this" do
        let(:path) { "/foo/bar/baz/" }
        it{ is_expected.not_to be_valid}
      end

      context "when same directory exists" do
        let(:path) { "/foo/bar/" }
        it{ is_expected.not_to be_valid}
      end

      # 保存はcase sensitiveで行うが、case insensitiveで重複判定は行う
      context "when same directory found, case insensitive" do
        let(:path) { "/foO/baR/" }
        it{ is_expected.not_to be_valid}
      end

      context "when differ" do
        let(:path) { "/foo/baz/" }
        it{ is_expected.to be_valid }

        it "count corrent" do
          subject
          expect(CrawlDirectory.count).to eq 2
        end
      end

      context "when differ 2" do
        let(:path) { "/gat/bar/" }
        it{ is_expected.to be_valid }

        it "count corrent" do
          subject
          expect(CrawlDirectory.count).to eq 2
        end
      end
    end

    it "stores path as case sensitive" do
      allow(Dir).to receive(:exist?).and_return(true)
      path = "/Foo/bAr"
      cd = CrawlDirectory.create(path: path)
      expect(cd.path).to eq path
    end
  end

  describe "#mark_as_deleted" do
    let(:cd) { CrawlDirectory.create(path: "/valid") }
    describe "deleted_at" do
      before { cd.mark_as_deleted }
      subject { cd.deleted_at}
      it { is_expected.to be_within(1.minutes).of(Time.current) }
    end

    describe "#deleted?" do
      before { cd.mark_as_deleted }
      subject { cd.deleted?}
      it { is_expected.to eq true }
    end
  end

end
