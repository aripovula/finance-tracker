require "test_helper"

class BankAccountTest < ActiveSupport::TestCase
  test "belongs to a user" do
    assert_equal users(:one), bank_accounts(:one).user
  end

  test "invalid without a user" do
    bank_account = BankAccount.new(bank_accounts_attributes.merge(user: nil))
    assert_not bank_account.valid?
  end

  private

  def bank_accounts_attributes
    {
      plaid_item_id: "item-sandbox-3",
      plaid_access_token: "access-sandbox-3",
      plaid_account_id: "account-sandbox-3"
    }
  end
end
