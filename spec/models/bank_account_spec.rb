require "rails_helper"

RSpec.describe BankAccount, type: :model do
  it "belongs to a user" do
    expect(bank_accounts(:one).user).to eq(users(:one))
  end

  it "is invalid without a user" do
    bank_account = BankAccount.new(bank_accounts_attributes.merge(user: nil))
    expect(bank_account).not_to be_valid
  end

  it "encrypts plaid_access_token at rest" do
    bank_account = BankAccount.create!(bank_accounts_attributes.merge(user: users(:one), plaid_access_token: "secret-token"))

    raw_value = BankAccount.connection.select_value(
      "SELECT plaid_access_token FROM bank_accounts WHERE id = #{bank_account.id}"
    )

    expect(raw_value).not_to eq("secret-token")
    expect(bank_account.reload.plaid_access_token).to eq("secret-token")
  end

  it "is invalid without a plaid_item_id" do
    bank_account = BankAccount.new(bank_accounts_attributes.merge(user: users(:one), plaid_item_id: nil))
    expect(bank_account).not_to be_valid
  end

  it "is invalid without a plaid_access_token" do
    bank_account = BankAccount.new(bank_accounts_attributes.merge(user: users(:one), plaid_access_token: nil))
    expect(bank_account).not_to be_valid
  end

  it "is invalid with a duplicate plaid_account_id" do
    bank_account = BankAccount.new(bank_accounts_attributes.merge(user: users(:one), plaid_account_id: bank_accounts(:one).plaid_account_id))
    expect(bank_account).not_to be_valid
  end

  def bank_accounts_attributes
    {
      plaid_item_id: "item-sandbox-3",
      plaid_access_token: "access-sandbox-3",
      plaid_account_id: "account-sandbox-3"
    }
  end
end
