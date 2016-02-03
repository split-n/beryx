require 'rails_helper'

RSpec.describe PlayHistory, type: :model do
  context "new" do
    context "valid model args" do
      let(:video) { FG.create(:video) }
      let(:user) { FG.create(:user) }

      subject { user.play_histories.create(video: video, position: position) }

      context "valid posittion" do
        let(:position) { 3 }
        it { should be_valid }
      end

      context "position is over video duration" do
        let(:position) { video.duration + 100 }
        it { should_not be_valid }
        it { expect(subject.errors[:position]).to include include "must be shorter than video's duration" }
      end

      context "position is minus" do
        let(:position) { -4 }
        it { should_not be_valid }
        it { expect(subject.errors[:position]).to include include "must be greater than or equal to 0" }
      end
    end
  end
end
