# == Schema Information
#
# Table name: play_histories
#
#  id         :integer          not null, primary key
#  video_id   :integer          not null
#  user_id    :integer          not null
#  position   :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_play_histories_on_user_id   (user_id)
#  index_play_histories_on_video_id  (video_id)
#
# Foreign Keys
#
#  fk_rails_325b78ed95  (user_id => users.id)
#  fk_rails_ea88ab6097  (video_id => videos.id)
#

class PlayHistory < ActiveRecord::Base
  belongs_to :video
  belongs_to :user
  validates :video, presence: true
  validates :user, presence: true
  validates :position, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validate :position_should_not_over_duration


  def position_should_not_over_duration
    if position > video.duration
      errors.add(:position, "must be shorter than video's duration")
    end
  end
end
