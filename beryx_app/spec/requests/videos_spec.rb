require 'rails_helper'

RSpec.describe "Videos", type: :request do
  describe "POST /videos/:id/convert" do
    let(:video) { FG.create(:video) }

    context "not logged" do
      it "redirected to login" do
        post "/videos/#{video.id}/convert"
        expect(response).to redirect_to login_path
      end
    end

    context "logged" do
      let(:user) { FG.create(:user) }
      before { log_in_as(user) }

      context "no params" do
        subject { post "/videos/#{video.id}/convert" }
        it { subject; expect(response.status).to eq 400 }
        it { subject; expect(response.body).to include "request body is invalid" }
      end

      context "video not found" do
        let(:request_body) { JSON.generate({convert_method: "HLS_COPY"}) }
        subject { post "/videos/60515/convert", request_body  }
        it { subject; expect(response.status).to eq 400 }
        it { subject; expect(response.body).to include "video_id is invalid" }
      end

      context "HLS_COPY" do
        let(:request_body) { JSON.generate({convert_method: "HLS_COPY"}) }
        subject { post "/videos/#{video.id}/convert", request_body  }
        it { subject; expect(response.status).to eq 200 }
        it { subject; expect(response.body).to include "m3u8" }
      end

      context "HLS_AVC_AAC_ENCODE" do

        subject { post "/videos/#{video.id}/convert", request_body  }
        context "params missing" do
          let(:request_body) {
            JSON.generate({
              convert_method: "HLS_AVC_AAC_ENCODE",
              convert_params: {
                  video_kbps: 1000
              }})
          }
          it { subject; expect(response.status).to eq 400 }
          it { subject; expect(response.body).to include "convert_params is invalid" }
        end

        context "valid convert params" do
          let(:request_body) {
            JSON.generate({
              convert_method: "HLS_AVC_AAC_ENCODE",
              convert_params: {
                  video_kbps: 1000, audio_kbps: 128,
                  height: 480, preset: "fast"
              }})
          }
          it { subject; expect(response.status).to eq 200 }
          it { subject; expect(response.body).to include "m3u8" }
        end

      end

    end
  end
end
