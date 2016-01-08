require 'rails_helper'

RSpec.feature "login", type: :feature do
  let!(:user) { FG.create(:user) }
  it "wrong username" do
    visit login_path
    fill_in "user[login_id]", with: "foobar"
    fill_in "user[password]", with: user.password
    click_on "Login"
    expect(current_path).to eq login_path
  end
end
