class CrawlDirectory < ActiveRecord::Base
  validates :path, presence: true, format: {with: %r{\A/.*/\z}, message: "Path should start /, ending / ." }
  validate :path_should_exists
  validate :path_should_not_include_others
  has_many :videos, dependent: :destroy

  scope :active, -> { where("deleted_at IS NULL") }
  scope :deleted, -> { where("deleted_at IS NOT NULL") }

  def deleted?
    deleted_at.present?
  end

  def mark_as_deleted
    self.deleted_at = Time.current
    save
  end

  def can_mark_as_active?
    duplicated_directory.nil?
  end

  def mark_as_active
    return true unless deleted?

    if !can_mark_as_active?
      false
    else
      self.deleted_at = nil
      save
      true
    end
  end

  private
  def path_should_exists
    unless path.present? && Dir.exist?(path)
      errors.add(:path, "Path directory not found.")
    end
  end

  def path_should_not_include_others
    dup = duplicated_directory
    if dup
      errors.add(:path, "Path duplicated with #{dup.path}")
    end
  end

  def duplicated_directory
    CrawlDirectory.active.reject{|d| d.id == self.id }.select{|d| dir_includes?(d)}.first
  end

  def dir_includes?(d1)
    p1 = d1.path.downcase
    p2 = self.path.downcase
    p1.start_with?(p2) || p2.start_with?(p1)
  end
end
