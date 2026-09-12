class BankAccount < ApplicationRecord
  belongs_to :user

  encrypts :plaid_access_token
end
