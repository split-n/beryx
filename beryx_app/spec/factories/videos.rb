FactoryGirl.define do
  factory :video do
    path "/valid/foo/bar.mp4"
    file_size 200.megabytes
  end
end
