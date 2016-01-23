# == Schema Information
#
# Table name: existed_video_on_crawls
#
#  id                 :integer          not null, primary key
#  video_id           :integer          not null
#  crawl_directory_id :integer          not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_existed_video_on_crawls_on_crawl_directory_id  (crawl_directory_id)
#  index_existed_video_on_crawls_on_video_id            (video_id)
#
# Foreign Keys
#
#  fk_rails_ae3892e0a2  (video_id => videos.id)
#  fk_rails_f8d3980150  (crawl_directory_id => crawl_directories.id)
#

class ExistedVideoOnCrawl < ActiveRecord::Base
  belongs_to :video
  belongs_to :crawl_directory
end
