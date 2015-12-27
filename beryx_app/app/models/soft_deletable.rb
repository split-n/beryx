module SoftDeletable
  extend ActiveSupport::Concern
  included do
    scope :active, -> { where("deleted_at IS NULL") }
    scope :deleted, -> { where("deleted_at IS NOT NULL") }
  end

  def deleted?
    deleted_at.present?
  end

  def mark_as_deleted(time=Time.current)
    self.deleted_at = time
    save!
  end

  def can_mark_as_active?
    true
  end

  def mark_as_active
    return true unless deleted?

    if !can_mark_as_active?
      false
    else
      self.deleted_at = nil
      save!
      true
    end
  end
end