require 'rails_helper'

RSpec.describe CrawlDirectoriesController, type: :controller do
  shared_examples "login_required" do
    it "redirected to login" do
      subject
      expect(response).to redirect_to login_path
    end
  end

  shared_context "not_logged" do
  end

  shared_context "logged_normal_user" do
    let(:user) { FG.create(:user) }
    before { log_in_as(user) }
  end

  shared_context "logged_admin_user" do
    let(:user) { FG.create(:user_admin) }
    before { log_in_as(user) }
  end



  describe "#index" do
    subject {
      get :index
    }

    context "not logged" do
      include_context "not_logged"
      it_behaves_like "login_required"
    end

    context "logged with normal user" do
      include_context "logged_normal_user"
      it_behaves_like "login_required"
    end

    context "logged with admin user" do
      include_context "logged_admin_user"
      it "can get" do
        subject
        expect(response).to render_template :index
      end
    end
  end

  describe "#show" do

    context "invalid id" do
      subject {
        get :show, id: 5005
      }

      context "not logged" do
        include_context "not_logged"
        it_behaves_like "login_required"
      end

      context "logged with normal user" do
        include_context "logged_normal_user"
        it_behaves_like "login_required"
      end

      context "logged with admin user" do
        include_context "logged_admin_user"
        it "renders 404" do
          subject
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    subject {
      get :show, id: crawl_directory.id
    }


  end
end
