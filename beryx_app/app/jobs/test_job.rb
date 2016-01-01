class TestJob < ActiveJob::Base
  queue_as :default

  def perform(*args)
    system("date >> /tmp/date")
  end
end
