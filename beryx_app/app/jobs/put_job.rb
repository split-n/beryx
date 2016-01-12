class PutJob < ActiveJob::Base
  queue_as :default

  def perform(prefix="")
    40.times do
      File.open("/tmp/out.txt", "a") do |f|
        f.puts "#{prefix} #{Time.now.to_s}"
      end
      sleep 1
    end
  end
end
