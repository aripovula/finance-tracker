class Budget < ApplicationRecord
  belongs_to :user
  belongs_to :category

  validates :monthly_limit_cents, presence: true
  validates :effective_month, presence: true
  validates :category_id, uniqueness: { scope: [ :user_id, :effective_month ] }
end
