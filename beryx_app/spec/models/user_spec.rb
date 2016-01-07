require 'rails_helper'

RSpec.describe User, type: :model do
  describe "on create" do
    describe "login_id" do
      let(:password) { "password" }
      subject{ User.create(login_id: login_id, password: password) }

      context "length is 3" do
        let(:login_id) { "foo" }
        it { should be_valid }
      end

      context "only underscore" do
        let(:login_id) { "______" }
        it { should be_valid }
      end

      context "is nil" do
        let(:login_id) { nil }
        it { should_not be_valid}
      end

      context "length is 2" do
        let(:login_id) { "fo" }
        it { should_not be_valid}
      end

      context "contain hyphen" do
        let(:login_id) { "foo-bar" }
        it { should_not be_valid}
      end

      context "contain space" do
        let(:login_id) { "foo bar" }
        it { should_not be_valid}
      end

      context "length is 20" do
        let(:login_id) { "a"*20 }
        it { should be_valid}
      end

      context "length is 21" do
        let(:login_id) { "a"*21 }
        it { should_not be_valid}
      end

      context "only numeric" do
        let(:login_id) { "12345" }
        it { should be_valid}
      end
    end

    describe "password" do
      let(:login_id) { "foobar" }
      subject{ User.create(login_id: login_id, password: password ) }

      context "is not set" do
        let(:password) { nil }
        it { should_not be_valid }
      end

      context "length is 6" do
        let(:password) { "a"*6 }
        it { should_not be_valid }
      end

      context "length is 7" do
        let(:password) { "a"*7 }
        it { should be_valid }
      end

    end

    describe "password confirmation" do
      let(:login_id) { "foobar" }
      subject{ User.create(login_id: login_id, password: password, password_confirmation: password_confirmation) }

      context "is valid" do
        let(:password) { "password" }
        let(:password_confirmation) { password }
        it { should be_valid }
      end

      context "is not set" do
        let(:password) { "password" }
        let(:password_confirmation) { nil }
        it { should be_valid }
      end

      context "is set but password is not set" do
        let(:password) { nil }
        let(:password_confirmation) { "password" }
        it { should_not be_valid }
      end

      context "is differ" do
        let(:password) {  "password" }
        let(:password_confirmation) { "passxxxx" }
        it { should_not be_valid }
      end

    end
  end
end
