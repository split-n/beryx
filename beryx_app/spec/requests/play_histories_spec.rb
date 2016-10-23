require 'rails_helper'

RSpec.describe "PlayHistories", type: :request do
  describe "GET /videos/:id/play_history" do
    let(:video) { FG.create(:video) }

    context "not logged" do
      it "redirected to login" do
        get "/videos/#{video.id}/play_history"
        expect(response).to redirect_to login_path
      end
    end

    context "logged" do
      let(:user) { FG.create(:user) }
      before { log_in_as(user) }

      context "exist" do
        let!(:ph) { FG.create(:play_history, video: video, user: user) }
        subject { get "/videos/#{video.id}/play_history" }
        it { subject; expect(response.status).to eq 200 }
        it "responses position" do
          subject
          body = JSON.parse(response.body)
          expect(body["position"]).to eq ph.position
        end
      end

      context "user's history not exist" do
        subject { get "/videos/#{video.id}/play_history" }
        it { subject; expect(response.status).to eq 404 }
      end

      context "video's history not exist" do
        let(:video2) { FG.create(:video) }
        let!(:ph) { FG.create(:play_history, video: video, user: user) }
        subject { get "/videos/#{video2.id}/play_history" }
        it { subject; expect(response.status).to eq 404 }
      end
    end
  end

  describe "POST /videos/:id/play_history" do
    let(:video) { FG.create(:video) }

    context "not logged" do
      it "redirected to login" do
        post "/videos/#{video.id}/play_history"
        expect(response).to redirect_to login_path
      end
    end

    context "logged" do
      let(:user) { FG.create(:user) }
      before { log_in_as(user) }

      context "correct request" do
        let(:position) { 3 }
        let(:request_body) { { position: position } }
        subject { post "/videos/#{video.id}/play_history", params: request_body }
        it { expect{subject}.to change{PlayHistory.count}.by(1) }
        it { subject; expect(response.status).to eq 200 }
      end
    end
  end
end
