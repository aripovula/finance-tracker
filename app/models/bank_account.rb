class BankAccount < ApplicationRecord
  belongs_to :user
  has_many :transactions

  encrypts :plaid_access_token

  validates :plaid_item_id, presence: true
  validates :plaid_access_token, presence: true
  validates :plaid_account_id, presence: true, uniqueness: true
end
