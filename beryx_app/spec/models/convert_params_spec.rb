require 'rails_helper'

shared_context "valid command args" do
  let(:src_file) { "/path/to/src.mp4" }
  let(:dest_dir) { "/paxx/to/dst" }
  let(:dest_file) { "/paxx/to/dst/playlist.m3u8" }
end

describe ConvertParams::CopyHls do
  describe "#to_command" do
    let(:params) { ConvertParams::CopyHls.new(params_hash) }
    subject {
      params.to_command(src_file, dest_dir, dest_file)
    }
    context "valid params/args" do
      include_context "valid command args"

      let(:params_hash) { {} }

      it { should include "ffmpeg" }
      it { should include src_file }
      it { should include dest_file }
    end
  end
end

describe ConvertParams::EncodeAvcAacHls do
  describe "#to_command" do
    let(:params) { ConvertParams::EncodeAvcAacHls.new(params_hash) }
    subject {
      params.to_command(src_file, dest_dir, dest_file)
    }
    context "valid params/args" do
      include_context "valid command args"
      let(:params_hash) { { audio_kbps: 128, video_kbps: 1024, height: 720 } }

      it { should include "ffmpeg" }
      it { should include src_file }
      it { should include dest_file }
      it { should include "#{params_hash[:audio_kbps]}k" }
      it { should include "#{params_hash[:video_kbps]}k" }
      it { should include "#{params_hash[:height]}" }
      it { should include "fast" }
      it { should_not include "tune" }
    end

    context "valid params/args extra" do
      include_context "valid command args"
      let(:params_hash) { { audio_kbps: 128, video_kbps: 1024, height: 720, preset: "slow", tune: "animation" } }

      it { should include "ffmpeg" }
      it { should include src_file }
      it { should include dest_file }
      it { should include "#{params_hash[:audio_kbps]}k" }
      it { should include "#{params_hash[:video_kbps]}k" }
      it { should include "#{params_hash[:height]}" }
      it { should include "#{params_hash[:preset]}" }
      it { should include "#{params_hash[:tune]}" }
    end

    context "invalid params" do
      let(:params_hash) { { audio_kbps: 128, video_kbps: 1024} }
      it { expect(params).not_to be_valid }
      it { expect{subject}.to raise_error StandardError}
    end
  end
end