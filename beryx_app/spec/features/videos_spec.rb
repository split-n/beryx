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
    it "can get empty list" do
      visit root_path
      expect(page).to have_content "Videos"
      expect(page).not_to have_selector "td"
    end

    it "can get videos list" do
      video = FG.create(:video)
      visit root_path
      expect(page).to have_link video.file_name, href: "/videos/#{video.id}"
    end

    it "can filter video by file name" do
      cd = FG.create(:crawl_directory)
      not_match_videos = [
          FG.create(:video, crawl_directory: cd, path: "#{cd.path}ほげ.mp4"),
          FG.create(:video, crawl_directory: cd, path: "#{cd.path}hoge_dir/fuga.mp4"),
          FG.create(:video, crawl_directory: cd, path: "#{cd.path}ho/ge.mp4"),
      ]
      match_videos = [
          FG.create(:video, crawl_directory: cd, path: "#{cd.path}foo/aＨｏｇｅze.mp4"),
          FG.create(:video, crawl_directory: cd, path: "#{cd.path}the_hoge_movie.mp4"),
          FG.create(:video, crawl_directory: cd, path: "#{cd.path}HOGE.mp4"),
      ]

      visit root_path
      fill_in "q_normalized_file_name_cont_all", with: "hoGe"
      click_button "Search"

      not_match_videos.each do |video|
        expect(page).not_to have_content video.file_name
      end
      match_videos.each do |video|
        expect(page).to have_link video.file_name, href: "/videos/#{video.id}"
      end

      expect(page).to have_content "#{match_videos.count} videos found"
    end
  end
end
