namespace :converted_videos do
  task :clean_all => :environment do
    ConvertedVideo.destroy_all
  end

  task :clean_24h => :environment do
    ConvertedVideo.where(ConvertedVideo.arel_table[:last_played].lt(1.day.ago)).destroy_all
  end
end
