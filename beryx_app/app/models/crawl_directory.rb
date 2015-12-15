class CrawlDirectory < ActiveRecord::Base
  validates :path, presence: true, format: {with: %r{\A/.*/\z}, message: "Path should start /, ending / ." }
  validate :path_should_exists
  validate :path_should_not_include_others
  has_many :videos, dependent: :destroy

  private
  def path_should_exists
    unless path.present? && Dir.exist?(path)
      errors.add(:path, "Path directory not found.")
    end
  end

  def path_should_not_include_others
    all = CrawlDirectory.all
    included = all.reject{|d| d.id == self.id }
                   .select{|d| dir_includes?(d, self)}
    unless included.empty?
      errors.add(:path, "Path duplicated with #{included.first.path}")
    end
  end

  def dir_includes?(d1, d2)
    d1.path.start_with?(d2.path) || d2.path.start_with?(d1.path)
  end
end
