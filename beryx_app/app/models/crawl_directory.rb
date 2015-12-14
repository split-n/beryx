class CrawlDirectory < ActiveRecord::Base
  validates :path, presence: true
  validate :path_should_exists

  private
  def path_should_exists
    unless Dir.exists?(path)
      errors.add(:path, "Path directory not found.")
    end
  end
end
