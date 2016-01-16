# == Schema Information
#
# Table name: converted_videos
#
#  id                  :integer          not null, primary key
#  video_id            :integer          not null
#  param_class         :string           not null
#  param_json          :text             not null
#  converted_file_path :string           not null
#  converted_dir_path  :string           not null
#  job_status          :integer          not null
#  jid                 :string
#  last_played         :datetime         not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
# Foreign Keys
#
#  fk_rails_e38e5798d7  (video_id => videos.id)
#

class ConvertedVideo < ActiveRecord::Base
  belongs_to :video
end
