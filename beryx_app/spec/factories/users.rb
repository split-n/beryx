FactoryGirl.define do
  factory :user do
    sequence(:login_id) {|n| "test_user#{n}" }
    password "password"
    password_confirmation "password"
  end
end
