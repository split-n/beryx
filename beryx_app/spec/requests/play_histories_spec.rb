require 'rails_helper'

RSpec.describe "PlayHistories", type: :request do
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
        subject { post "/videos/#{video.id}/play_history", request_body }
        it { expect{subject}.to change{PlayHistory.count}.by(1) }
        it { subject; expect(response.status).to eq 200 }
      end
    end
  end
end
