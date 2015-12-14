class CrawlDirectory < ActiveRecord::Base
  validates :path, presence: true
  validate :path_should_exists
  has_many :videos, dependent: :destroy

  private
  def path_should_exists
    unless Dir.exists?(path)
      errors.add(:path, "Path directory not found.")
    end
  end
end
