class MonthlySummary < ApplicationRecord
  belongs_to :user
  belongs_to :category

  validates :month, presence: true
  validates :total_spent_cents, presence: true
  validates :category_id, uniqueness: { scope: [ :user_id, :month ] }
end
