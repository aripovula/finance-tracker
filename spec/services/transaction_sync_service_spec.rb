require "rails_helper"

RSpec.describe TransactionSyncService do
  # Built via AR (not the bank_accounts fixture) so plaid_access_token is
  # actually encrypted — fixtures bypass ActiveRecord Encryption entirely.
  let(:bank_account) do
    BankAccount.create!(
      user: users(:one), plaid_item_id: "item-sandbox-sync",
      plaid_access_token: "access-sandbox-sync", plaid_account_id: "account-sandbox-sync"
    )
  end

  describe "#call" do
    it "upserts added transactions and advances the cursor" do
      plaid_transaction = instance_double(
        Plaid::Transaction,
        transaction_id: "txn-sandbox-new",
        amount: 42.5,
        merchant_name: "Chipotle",
        name: "CHIPOTLE 1234",
        datetime: nil,
        date: Date.new(2026, 9, 1),
        pending: false,
        to_hash: { "transaction_id" => "txn-sandbox-new" }
      )
      response = instance_double(
        Plaid::TransactionsSyncResponse,
        added: [ plaid_transaction ], modified: [], removed: [],
        next_cursor: "cursor-1", has_more: false
      )
      fake_client = instance_double(Plaid::PlaidApi, transactions_sync: response)
      allow(PlaidClient).to receive(:client).and_return(fake_client)

      expect {
        described_class.new.call(bank_account)
      }.to change { Transaction.count }.by(1)

      transaction = Transaction.find_by(plaid_transaction_id: "txn-sandbox-new")
      expect(transaction.amount_cents).to eq(4250)
      expect(transaction.merchant_name).to eq("Chipotle")
      expect(transaction.status).to eq("posted")
      expect(bank_account.reload.plaid_cursor).to eq("cursor-1")
    end

    it "removes transactions Plaid reports as removed" do
      removed = instance_double(Plaid::RemovedTransaction, transaction_id: transactions(:one).plaid_transaction_id)
      response = instance_double(
        Plaid::TransactionsSyncResponse,
        added: [], modified: [], removed: [ removed ],
        next_cursor: "cursor-2", has_more: false
      )
      fake_client = instance_double(Plaid::PlaidApi, transactions_sync: response)
      allow(PlaidClient).to receive(:client).and_return(fake_client)

      expect {
        described_class.new.call(bank_account)
      }.to change { Transaction.count }.by(-1)
    end

    it "pages through results until has_more is false" do
      first_page = instance_double(
        Plaid::TransactionsSyncResponse,
        added: [], modified: [], removed: [],
        next_cursor: "cursor-page-1", has_more: true
      )
      second_page = instance_double(
        Plaid::TransactionsSyncResponse,
        added: [], modified: [], removed: [],
        next_cursor: "cursor-page-2", has_more: false
      )
      fake_client = instance_double(Plaid::PlaidApi)
      allow(fake_client).to receive(:transactions_sync).and_return(first_page, second_page)
      allow(PlaidClient).to receive(:client).and_return(fake_client)

      described_class.new.call(bank_account)

      expect(fake_client).to have_received(:transactions_sync).twice
      expect(bank_account.reload.plaid_cursor).to eq("cursor-page-2")
    end
  end
end
