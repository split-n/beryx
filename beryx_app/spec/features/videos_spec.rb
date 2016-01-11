require 'rails_helper'

RSpec.feature "Videos", type: :feature do
  context "without login" do
    it "redirected to login" do
      visit root_path
      expect(current_path).to eq login_path
    end
  end

  context "with normal user" do
    let(:user) { FG.create(:user) }
    before { log_in_as(user) }
    it "gets empty list" do
      visit root_path
      expect(page).to have_content "Videos"
      expect(page).not_to have_selector "li a"
    end

    it "gets videos list" do
      video = FG.create(:video)
      visit root_path
      expect(page).to have_selector "li a", text: video.file_name
    end
  end
end
