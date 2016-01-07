FactoryGirl.define do
  factory :user do
    sequence(:login_id) {|n| "test_user#{n}" }
    password "password"
    factory :user_admin do
      admin true
    end
  end
end
