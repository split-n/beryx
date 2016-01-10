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
end
