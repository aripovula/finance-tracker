class Category < ApplicationRecord
  belongs_to :parent_category, class_name: "Category", optional: true
  has_many :subcategories, class_name: "Category", foreign_key: :parent_category_id, dependent: :nullify
  has_many :transactions
  has_many :budgets
  has_many :monthly_summaries

  validates :name, presence: true
end
