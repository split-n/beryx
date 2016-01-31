require 'rails_helper'

RSpec.feature "CrawlDirectories", type: :feature do
  describe "get /crawl_directories" do
    context "with normal user" do
      let!(:user) { FG.create(:user) }
      before { log_in_as(user) }
      it "redirected to login" do
        visit crawl_directories_path
        expect(current_path).to eq login_path
      end
    end

    context "with admin user" do
      let!(:user) { FG.create(:user_admin) }
      before { log_in_as(user) }

      it "can get page and empty list" do
        visit crawl_directories_path
        expect(page).not_to have_content "Destroy"
        expect(page).to have_content "Crawl Directories"
      end

      it "can get list with item" do
        cd = FG.create(:crawl_directory)
        visit crawl_directories_path
        expect(page).to have_content cd.path
      end
    end
  end

  describe "create new" do
    let(:user) { FG.create(:user_admin) }
    before { log_in_as(user) }

    it "can register new directory" do
      path = "/valid/abc/"
      allow(Dir).to receive(:exist?).with(path).and_return(true)

      expect {
        visit new_crawl_directory_path
        fill_in "crawl_directory_path", with: path
        click_button "Create Crawl directory"
      }.to change{CrawlDirectory.active.count}.by(1)
    end

    it "can't register dup directory, show errors" do
      existed = FG.create(:crawl_directory)
      allow(Dir).to receive(:exist?).with(existed.path).and_return(true)

      expect {
        visit new_crawl_directory_path
        fill_in "crawl_directory_path", with: existed.path
        click_button "Create Crawl directory"
      }.not_to change{CrawlDirectory.active.count}
      expect(page).to have_content "Path duplicated"
    end
  end

  describe "get /crawl_directories/:id" do
    context "with normal user" do
      let!(:user) { FG.create(:user) }
      let!(:cd) { FG.create(:crawl_directory) }
      before { log_in_as(user) }
      it "redirected to login" do
        visit crawl_directory_path(cd)
        expect(current_path).to eq login_path
      end
    end

    context "with admin user" do
      let!(:user) { FG.create(:user_admin) }
      let!(:cd) { FG.create(:crawl_directory) }
      before { log_in_as(user) }
      it "gets" do
        visit crawl_directory_path(cd)
        expect(page).to have_content cd.path
      end

      it "has start crawl button" do
        visit crawl_directory_path(cd)
        expect(page).to have_button "Execute crawl"
      end

      it "start button disabled when job running" do
        cd.crawl_job_status = :running
        cd.save!
        visit crawl_directory_path(cd)
        expect(page).to have_content "Job running"
        expect(page).to have_css "button[disabled]"
      end
    end
  end

end
