class Transaction < ApplicationRecord
  belongs_to :bank_account
  belongs_to :category, optional: true

  enum :status, { pending: "pending", posted: "posted" }
end
