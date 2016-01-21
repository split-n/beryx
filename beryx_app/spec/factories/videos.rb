FactoryGirl.define do
  factory :video do
    after(:build) do |video|
      allow(File).to receive(:exist?).with(video.path).and_return(true)
      allow(video).to receive(:get_duration).and_return(24.minutes)
    end
    crawl_directory
    sequence(:path) {|n| "#{crawl_directory.path}foo#{n}.mp4" }
    file_size 200.megabytes
    file_timestamp { 2.days.ago }
  end
end
