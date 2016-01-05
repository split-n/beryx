FactoryGirl.define do
  factory :video do
    after(:build) do |video|
      allow(File).to receive(:exist?).with(video.path).and_return(true)
    end
    crawl_directory
    sequence(:path) {|n| "#{crawl_directory.path}foo#{n}.mp4" }
    file_size 200.megabytes
  end
end
