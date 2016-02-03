require 'rails_helper'

RSpec.describe PlayHistory, type: :model do
  context "new" do
    context "valid model args" do
      let(:video) { FG.create(:video) }
      let(:user) { FG.create(:user) }

      context "first time" do
        subject { PlayHistory.destroy_and_create(user.id, video.id, position) }
        context "valid posittion" do
          let(:position) { 3 }
          it { should be_valid }
          it { expect{subject}.to change{PlayHistory.count}.by(1) }
        end

        context "position is over video duration" do
          let(:position) { video.duration + 100 }
          it { should_not be_valid }
          it { expect(subject.errors[:position]).to include include "must be shorter than video's duration" }
          it { expect{subject}.not_to change{PlayHistory.count} }
        end

        context "position is minus" do
          let(:position) { -4 }
          it { should_not be_valid }
          it { expect(subject.errors[:position]).to include include "must be greater than or equal to 0" }
          it { expect{subject}.not_to change{PlayHistory.count} }
        end
      end

      context "second time" do
        before { PlayHistory.destroy_and_create(user.id, video.id, position) }
        subject { PlayHistory.destroy_and_create(user.id, video.id, position2) }
        context "valid position" do
          let(:position) { 4 }
          let(:position2) { 2 }
          it { should be_valid }
          it { expect{subject}.not_to change{PlayHistory.count} }
        end

        context "second create's duration wrong" do
          let(:position) { 4 }
          let(:position2) { -1 }
          it { should_not be_valid }
          it { expect{subject}.not_to change{PlayHistory.count} }
        end
      end
    end
  end
end
