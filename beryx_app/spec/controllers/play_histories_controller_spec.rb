require 'rails_helper'

RSpec.describe PlayHistoriesController, type: :controller do
  describe "#index" do
    let!(:user) { FG.create(:user) }
    let!(:videos) { FG.create_list(:video, 15) }
    before {
      log_in_as(user)
    }
    it "assigns active videos only, order by updated_at desc" do

    end
  end
end
