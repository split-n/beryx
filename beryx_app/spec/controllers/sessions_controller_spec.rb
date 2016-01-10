require 'rails_helper'

RSpec.describe SessionsController, type: :controller do
  let(:user) { FG.create(:user) }
  let(:user_admin) { FG.create(:user_admin) }

  describe "#new" do
    it "normal" do
       get :new
      expect(response).to render_template :new
    end
  end

  describe "#create" do
    it "normal user login" do
      post :create, user: { login_id: user.login_id, password: user.password }
      expect(response).to redirect_to root_path
      expect(session[:user_id]).to eq user.id
    end

    it "admin user login" do
      post :create, user: { login_id: user_admin.login_id, password: user_admin.password }
      expect(response).to redirect_to root_path
      expect(session[:user_id]).to eq user_admin.id
    end

    it "wrong input" do
      post :create, user: { login_id: "foobar", password: "12345678" }
      expect(response).to render_template :new
      expect(session[:user_id]).to eq nil
    end
  end

  describe "#destroy" do
    it "work logout" do
      log_in_as(user)
      delete :destroy
      expect(response).to redirect_to login_path
      expect(session[:user_id]).to eq nil
    end

    it "noop when not logged" do
      delete :destroy
      expect(response).to redirect_to login_path
      expect(session[:user_id]).to eq nil
    end
  end
end