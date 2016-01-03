FactoryGirl.define do
  factory :crawl_directory do
    after(:build) do |cd|
      allow(Dir).to receive(:exist?).with(cd.path).and_return(true)
    end
    sequence(:path) {|n| "/valid/foo#{n}/" }
  end
end
