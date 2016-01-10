require 'rails_helper'

RSpec.feature "login", type: :feature do
  let!(:user) { FG.create(:user) }
  let!(:user_admin) { FG.create(:user_admin) }

  it "with wrong username" do
    visit login_path
    fill_in "user[login_id]", with: "foobar"
    fill_in "user[password]", with: user.password
    click_on "Login"
    expect(current_path).to eq login_path
  end

  it "with wrong password" do
    visit login_path
    fill_in "user[login_id]", with: user.login_id
    fill_in "user[password]", with: "pass12345"
    click_on "Login"
    expect(current_path).to eq login_path
  end

  it "with normal user" do
    visit login_path
    fill_in "user[login_id]", with: user.login_id
    fill_in "user[password]", with: user.password
    click_on "Login"
    expect(current_path).to eq root_path
  end

  it "with admin user" do
    visit login_path
    fill_in "user[login_id]", with: user_admin.login_id
    fill_in "user[password]", with: user_admin.password
    click_on "Login"
    expect(current_path).to eq root_path
  end
end
