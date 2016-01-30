require 'rails_helper'

RSpec.describe VideosController, type: :controller do
  describe "#index" do
    context "not logged" do
      it "redirected to login" do
        get :index
        expect(response).to redirect_to login_path
      end
    end

    context "logged with normal user" do
      let(:user) { FG.create(:user) }
      it "can get" do
        log_in_as(user)
        get :index
        expect(response).to render_template :index
      end
    end
  end

  describe "#show" do
    context "not logged" do
      it "redirected to login" do
        get :index
        expect(response).to redirect_to login_path
      end
    end

    context "logged with normal user" do
      let(:user) { FG.create(:user) }
      before { log_in_as(user) }

      context "valid video" do
        let(:video) { FG.create(:video) }
        subject { get :show, id: video.id }
        it { subject; expect(response).to render_template :show }
      end

      context "not found video_id" do
        subject { get :show, id: 45516 }
        it { expect{subject}.to raise_error(ActiveRecord::RecordNotFound) }
      end

      context "mark as deleted video" do
        let(:video) { FG.create(:video) }
        before { video.mark_as_deleted }
        subject { get :show, id: video.id }
        it { expect{subject}.to raise_error(ActiveRecord::RecordNotFound) }
      end

      context "video file is deleted" do
        let(:video) { FG.create(:video) }
        before { allow(File).to receive(:exist?).with(video.path).and_return(false) }
        subject { get :show, id: video.id }
        it { expect{subject}.to raise_error(ActiveRecord::RecordNotFound) }
      end
    end
  end
end
