require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  describe "#show" do
    context "not logged" do
      it "redirected to login" do
        get :show
        expect(response).to redirect_to login_path
      end
    end

    context "logged" do
      let(:user) { FG.create(:user) }
      before { log_in_as(user) }

      it "can get" do
        get :show
        expect(response).to render_template :show
      end
    end
  end
end
