FactoryGirl.define do
  factory :video do
    after(:build) do |video|
      allow(File).to receive(:exist?).with(video.path).and_return(true)
      allow(File).to receive(:size).with(video.path).and_return(200.megabytes)
      allow(File).to receive(:mtime).with(video.path).and_return(2.days.ago)
      allow(video).to receive(:get_duration).and_return(24.minutes)
    end
    crawl_directory
    sequence(:path) {|n| "#{crawl_directory.path}foo#{n}.mp4" }
  end
end
