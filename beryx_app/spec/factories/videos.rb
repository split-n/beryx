FactoryGirl.define do
  after(:build) do |video|
    allow(File).to receive(:exist?).with(video.path).and_return(true)
  end

  factory :video do
    path "/valid/foo/bar.mp4"
    file_size 200.megabytes
  end
end
