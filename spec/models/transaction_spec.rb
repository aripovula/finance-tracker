require "rails_helper"

RSpec.describe Transaction, type: :model do
  it "belongs to a bank_account" do
    expect(transactions(:one).bank_account).to eq(bank_accounts(:one))
  end

  it "is invalid without a bank_account" do
    transaction = Transaction.new(transactions_attributes.merge(bank_account: nil))
    expect(transaction).not_to be_valid
  end

  it "belongs to a category" do
    expect(transactions(:one).category).to eq(categories(:dining))
  end

  it "is valid without a category" do
    expect(transactions(:two)).to be_valid
  end

  it "reads pending status" do
    expect(transactions(:two)).to be_pending
  end

  it "can transition to posted status" do
    transaction = transactions(:two)
    transaction.posted!
    expect(transaction).to be_posted
  end

  it "is invalid without a plaid_transaction_id" do
    transaction = Transaction.new(transactions_attributes.merge(plaid_transaction_id: nil))
    expect(transaction).not_to be_valid
  end

  it "is invalid with a duplicate plaid_transaction_id" do
    transaction = Transaction.new(transactions_attributes.merge(plaid_transaction_id: transactions(:one).plaid_transaction_id))
    expect(transaction).not_to be_valid
  end

  it "is invalid without amount_cents" do
    transaction = Transaction.new(transactions_attributes.merge(amount_cents: nil))
    expect(transaction).not_to be_valid
  end

  def transactions_attributes
    {
      bank_account: bank_accounts(:one),
      plaid_transaction_id: "txn-sandbox-3",
      amount_cents: 999
    }
  end
end
