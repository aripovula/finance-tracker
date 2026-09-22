class BudgetAlert < ApplicationRecord
  belongs_to :budget

  validates :spent_cents, presence: true

  scope :active, -> { where(dismissed_at: nil) }
end
