require 'rails_helper'

RSpec.feature "CrawlDirectories", type: :feature do
  describe "/crawl_directories" do
    context "with normal user" do
      let!(:user) { FG.create(:user) }
      before {
        log_in_as(user)
      }
      it "redirected to login" do
        visit crawl_directories_path
        expect(current_path).to eq login_path
      end
    end

    context "with admin user" do
      let!(:user) { FG.create(:user_admin) }
      before {
        log_in_as(user)
      }

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

  describe "/crawl_directories/:id" do
    context "with normal user" do
      let!(:user) { FG.create(:user) }
      let!(:cd) { FG.create(:crawl_directory) }
      before {
        log_in_as(user)
      }
      it "redirected to login" do
        visit crawl_directory_path(cd)
        expect(current_path).to eq login_path
      end
    end

    context "with admin user" do
      let!(:user) { FG.create(:user_admin) }
      let!(:cd) { FG.create(:crawl_directory) }
      before {
        log_in_as(user)
      }
      it "gets" do
        visit crawl_directory_path(cd)
        expect(page).to have_content cd.path
      end
    end
  end

end
