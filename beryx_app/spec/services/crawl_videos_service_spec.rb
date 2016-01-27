require 'rails_helper'
require 'find'

RSpec.describe CrawlVideosService, truncation_spec: true do
  def mock_file_exists(path)
    allow(File).to receive(:exist?).with(path).and_return(true)
    allow(File).to receive(:size).with(path).and_return(300.megabyte)
    allow(File).to receive(:mtime).with(path).and_return(2.days.ago)
  end

  def mock_file_noent(path)
    allow(File).to receive(:exist?).with(path).and_return(false)
    allow(File).to receive(:size).with(path).and_raise(Errno::ENOENT)
    allow(File).to receive(:mtime).with(path).and_raise(Errno::ENOENT)
  end

  describe "#crawl_exist_videos_path" do
    let(:cd) { FG.create(:crawl_directory) }
    let(:cvs) { CrawlVideosService.new(cd) }
    subject { cvs.crawl_exist_videos_path }

    context "directory is removed" do
      before { expect(Dir).to receive(:exist?).with(cd.path).and_return(false) }
      it { expect{subject}.to raise_error(CrawlDirectory::PathNotFoundError) }
    end

    context "no files" do
      before { expect(Find).to receive(:find).with(cd.path).and_return([cd.path]) }
      it { expect(subject.to_a).to eq [] }
    end

    context "mixed files" do
      let(:vids) { ["#{cd.path}foo.mp4", "#{cd.path}sub/123/foo.mkv"] }
      let(:returns) { [cd.path, "#{cd.path}bar.txt"].concat(vids) }
      before { expect(Find).to receive(:find).with(cd.path).and_return(returns.to_enum) }

      it { expect(subject.to_a).to eq vids }
    end
  end

  describe "#crawl_videos_and_create" do
    let(:cd) { FG.create(:crawl_directory) }
    let(:cvs) { CrawlVideosService.new(cd) }
    subject { cvs.crawl_videos_and_create }

    context "directory is removed" do
      before { expect(Dir).to receive(:exist?).with(cd.path).and_return(false) }
      it { expect{subject}.to raise_error(CrawlDirectory::PathNotFoundError) }
    end

    context "video files exist" do
      context "video file invalid" do
        let(:file) { "#{cd.path}foo/a.mp4" }
        before {
          mock_file_exists(file)
          allow_any_instance_of(Video).to receive(:get_duration).and_return(nil)
          allow(Find).to receive(:find).with(cd.path).and_return([file])
        }
        after {
          allow_any_instance_of(Video).to receive(:get_duration).and_call_original
        }

        it { expect{subject}.not_to change{cd.videos.active.count} }
      end

      context "video file valid" do
        let(:returns) { %W(#{cd.path}foo/1.mp4 #{cd.path}foo/2.mkv #{cd.path}bar/3.mp4 #{cd.path}1.mp4) }
        before {
          allow_any_instance_of(Video).to receive(:get_duration).and_return(24.minutes)
          allow(Find).to receive(:find).with(cd.path).and_return(returns.to_enum)
          returns.each{|p| mock_file_exists(p) }
        }

        after {
          allow_any_instance_of(Video).to receive(:get_duration).and_call_original
        }

        it { expect{subject}.to change{Video.active.count}.from(0).to(returns.count)}
        it {
          subject
          expect(cd.videos.find_by(path: returns.first)).to be_present
        }

        context "crawled once, and file deleted" do
          before {
            cvs.crawl_videos_and_create
            @deleted_path = returns.delete_at(1)
            mock_file_noent(@deleted_path)
          }

          it { expect{subject}.to change{cd.videos.active.count}.by(-1) }
          it { expect{subject}.to change{cd.videos.deleted.count}.by(1) }
          it {
            subject
            deleted_video = cd.videos.find_by(path: @deleted_path)
            expect(deleted_video.deleted_at).to be_within(1.minute).of(Time.now)
          }
        end

        context "crawled once, and file size is changed" do
          before {
            cvs.crawl_videos_and_create
            @changed_path = returns.first
            allow(File).to receive(:size).with(@changed_path).and_return(573.megabytes)
          }
          it "returns same instance" do
            first_instance = Video.find_by(path: @changed_path)
            subject
            second_instance = Video.find_by(path: @changed_path)
            expect(first_instance).to eq second_instance
          end

          it { expect{subject}.to change{Video.find_by(path: @changed_path).file_size}.to(573.megabytes) }
        end

        context "crawled twice, and file status is still deleted" do
          before {
            cvs.crawl_videos_and_create
            @deleted_path = returns.delete_at(1)
            mock_file_noent(@deleted_path)
            cvs.crawl_videos_and_create
          }
          it { expect{subject}.not_to change{cd.videos.active.count} }
          it { expect{subject}.not_to change{cd.videos.deleted.count} }
          it { expect{subject}.not_to change{Video.find_by(path: @deleted_path).deleted_at}}
        end

        context "crawled twice, and deleted file is revived" do
          before {
            cvs.crawl_videos_and_create
            @deleted_path = returns.delete_at(1)
            mock_file_noent(@deleted_path)
            cvs.crawl_videos_and_create
            returns.unshift(@deleted_path)
            mock_file_exists(@deleted_path)
          }

          it { expect{subject}.to change{cd.videos.active.count}.by(1) }
          it { expect{subject}.to change{cd.videos.deleted.count}.by(-1) }
        end


        context "first cd has been deleted, new one revives deleted videos" do
          before {
            cvs.crawl_videos_and_create
            cd.mark_as_deleted
            @cd2 = FG.create(:crawl_directory, path: "#{cd.path}foo/")
            returns_in2 = returns.select{|p| p.start_with?(@cd2.path)}
            allow(Find).to receive(:find).with(@cd2.path).and_return(returns_in2.to_enum)
          }
          subject { CrawlVideosService.new(@cd2).crawl_videos_and_create }
          it { expect{subject}.to change{@cd2.videos.active.count}.from(0).to(2)}
          it { expect{subject}.to change{cd.videos.deleted.count}.from(returns.count).to(2)}
          it "video is same id" do
            target_path = returns.first
            old = cd.videos.deleted.find_by(path: target_path)
            subject
            new = @cd2.videos.active.find_by(path: target_path)
            expect(new).to eq old
          end
        end

        context "crawled once, and file is moved" do
          before {
            cvs.crawl_videos_and_create
            @deleted_path = returns.delete_at(0)
            @deleted_video = Video.find_by(path: @deleted_path)
            file_name = File.basename(@deleted_path)
            mock_file_noent(@deleted_path)
            @new_path = "#{cd.path}moved/#{file_name}"
            returns.unshift(@new_path)
            mock_file_exists(@new_path)
          }

          subject { cvs.crawl_videos_and_create }
          it { expect{subject}.not_to change{cd.videos.active.count} }
          it { expect{subject}.not_to change{cd.videos.deleted.count} }
          it "is same entity" do
            subject
            new_video = Video.find_by(path: @new_path)
            expect(@deleted_video).to eq new_video
          end
        end

        context "crawled once, and a file is deleted, a same name file is created" do
          before {
            cvs.crawl_videos_and_create
            @deleted_path = returns.delete_at(0)
            @deleted_video = Video.find_by(path: @deleted_path)
            file_name = File.basename(@deleted_path)
            mock_file_noent(@deleted_path)
            @new_path = "#{cd.path}neq/#{file_name}"
            returns.unshift(@new_path)
            allow(File).to receive(:exist?).with(@new_path).and_return(true)
            allow(File).to receive(:size).with(@new_path).and_return(777.megabyte)
            allow(File).to receive(:mtime).with(@new_path).and_return(2.days.ago)
          }

          subject { cvs.crawl_videos_and_create }
          it { expect{subject}.not_to change{cd.videos.active.count} }
          it { expect{subject}.to change{cd.videos.deleted.count}.by(1) }
          it "is not same entity" do
            subject
            new_video = Video.find_by(path: @new_path)
            expect(@deleted_video).not_to eq new_video
          end
        end
      end
    end
  end
end