require 'rails_helper'

RSpec.describe ConvertedVideo, type: :model do
  let!(:cd) { FG.create(:crawl_directory) }
  let!(:video) { FG.create(:video, crawl_directory: cd) }
  let(:dst_dir) { "/path/to/dst" }
  let(:dst_file) { dst_dir + "/file.m3u8" }

  describe ".convert_to" do
    context "works" do
      subject {
        ConvertedVideo.convert_to(video, ConvertParams::CopyHls.new, dst_dir, dst_file)
      }
      it { expect{subject}.to change{ConvertedVideo.count}.by(1) }
      it { expect(subject.converted_file_path).to eq dst_file }
      it { expect(subject.converted_dir_path).to eq dst_dir }
      it { expect(subject.param_class).to eq ConvertParams::CopyHls.name }
    end

    context "already queued" do
      it {
        cv1 = ConvertedVideo.convert_to(video, ConvertParams::CopyHls.new, dst_dir, dst_file)
        expect(ConvertedVideo.count).to eq 1
        cv2 = ConvertedVideo.convert_to(video, ConvertParams::CopyHls.new, dst_dir, dst_file)
        expect(ConvertedVideo.count).to eq 1
        expect(cv1.last_played).to be < cv2.last_played
      }
    end
  end
end
