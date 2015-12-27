class CrawlDirectory < ActiveRecord::Base
  include SoftDeletable
  validates :path, presence: true
  validates :path, format: {with: %r{\A/}, message: "must be started with /"}, if: -> { path.present? }
  validates :path, format: {with: %r{/\z}, message: "must be ended with /"}, if: -> { path.present? }
  validate :path_should_exists, if: -> { path.present? }
  validate :path_should_not_include_others, if: -> { path.present? }
  has_many :videos, dependent: :destroy

  def can_mark_as_active?
    duplicated_directory.nil?
  end

  def mark_as_deleted(time=Time.current)
    self.videos.active.find_each do |v|
      v.mark_as_deleted(time)
    end
    super(time)
  end

  def mark_as_active
    deleted_at = self.deleted_at
    succeed = super
    if succeed && deleted_at
      self.videos.deleted.where(deleted_at: deleted_at).find_each do |v|
        v.mark_as_active
      end
    end
    succeed
  end

  private
  def path_should_exists
    unless path.present? && Dir.exist?(path)
      errors.add(:path, "directory not found")
    end
  end

  def path_should_not_include_others
    dup = duplicated_directory
    if dup
      errors.add(:path, "duplicated with #{dup.path}")
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
