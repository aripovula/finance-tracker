require "test_helper"

class TransactionTest < ActiveSupport::TestCase
  test "belongs to a bank_account" do
    assert_equal bank_accounts(:one), transactions(:one).bank_account
  end

  test "invalid without a bank_account" do
    transaction = Transaction.new(transactions_attributes.merge(bank_account: nil))
    assert_not transaction.valid?
  end

  test "belongs to a category" do
    assert_equal categories(:dining), transactions(:one).category
  end

  test "valid without a category" do
    assert transactions(:two).valid?
  end

  test "reads pending status" do
    assert transactions(:two).pending?
  end

  test "can transition to posted status" do
    transaction = transactions(:two)
    transaction.posted!
    assert transaction.posted?
  end

  test "invalid without a plaid_transaction_id" do
    transaction = Transaction.new(transactions_attributes.merge(plaid_transaction_id: nil))
    assert_not transaction.valid?
  end

  test "invalid with a duplicate plaid_transaction_id" do
    transaction = Transaction.new(transactions_attributes.merge(plaid_transaction_id: transactions(:one).plaid_transaction_id))
    assert_not transaction.valid?
  end

  test "invalid without amount_cents" do
    transaction = Transaction.new(transactions_attributes.merge(amount_cents: nil))
    assert_not transaction.valid?
  end

  private

  def transactions_attributes
    {
      bank_account: bank_accounts(:one),
      plaid_transaction_id: "txn-sandbox-3",
      amount_cents: 999
    }
  end
end
