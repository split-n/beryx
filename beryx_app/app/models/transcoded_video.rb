# == Schema Information
#
# Table name: transcoded_videos
#
#  id               :integer          not null, primary key
#  video_id         :integer          not null
#  transcode_params :text             not null
#  rand             :string           not null
#  job_status       :integer          not null
#  jid              :string
#  last_played      :datetime         not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_transcoded_videos_on_video_id  (video_id)
#
# Foreign Keys
#
#  fk_rails_63252a304e  (video_id => videos.id)
#

class TranscodedVideo < ActiveRecord::Base
  enum job_status: { queued: 0, running: 1, done: 2 }
end
