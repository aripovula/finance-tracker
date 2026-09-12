class Transaction < ApplicationRecord
  belongs_to :bank_account
  belongs_to :category, optional: true
end
