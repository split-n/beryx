require 'rails_helper'

RSpec.describe CrawlDirectoriesController, type: :controller do
  describe "#index" do
    shared_examples "forbidden" do
      it "redirected to login" do
        get :index
        expect(response).to redirect_to login_path
      end
    end

    context "not logged" do
      it_behaves_like "forbidden"
    end

    context "logged with normal user" do
      let(:user) { FG.create(:user) }
      before { log_in_as(user) }
      it_behaves_like "forbidden"
    end

    context "logged with admin user" do
      let(:user) { FG.create(:user_admin) }
      before { log_in_as(user) }
      it "can get" do
        get :index
        expect(response).to render_template :index
      end
    end
  end
end
