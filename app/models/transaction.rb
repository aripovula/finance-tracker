class Transaction < ApplicationRecord
  belongs_to :bank_account
  belongs_to :category, optional: true

  enum :status, { pending: "pending", posted: "posted" }

  validates :plaid_transaction_id, presence: true, uniqueness: true
  validates :amount_cents, presence: true
end
