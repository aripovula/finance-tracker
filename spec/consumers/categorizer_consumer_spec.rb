require "rails_helper"

RSpec.describe CategorizerConsumer do
  let(:consumer) { described_class.new }

  def message_with(payload)
    instance_double(Karafka::Messages::Message, payload: payload)
  end

  describe "#consume" do
    it "syncs and categorizes transactions for the webhook's bank_account" do
      bank_account = bank_accounts(:one)
      payload = {
        "webhook_type" => "TRANSACTIONS", "webhook_code" => "SYNC_UPDATES_AVAILABLE",
        "item_id" => bank_account.plaid_item_id
      }
      allow(TransactionSyncService).to receive(:new).and_return(instance_double(TransactionSyncService, call: nil))
      transaction = Transaction.create!(
        bank_account: bank_account, plaid_transaction_id: "txn-categorize-me",
        amount_cents: 1500, posted_at: Time.current, status: "posted",
        raw_payload: { "personal_finance_category" => { "detailed" => categories(:restaurants).plaid_category_id.upcase } }
      )

      consumer.messages = [ message_with(payload) ]
      consumer.consume

      expect(transaction.reload.category).to eq(categories(:restaurants))
    end

    it "does nothing for non-transactions webhooks" do
      payload = { "webhook_type" => "ITEM", "webhook_code" => "ERROR" }
      consumer.messages = [ message_with(payload) ]

      expect(TransactionSyncService).not_to receive(:new)

      consumer.consume
    end

    it "does nothing when no bank_account matches the item_id" do
      payload = { "webhook_type" => "TRANSACTIONS", "item_id" => "unknown-item" }
      consumer.messages = [ message_with(payload) ]

      expect(TransactionSyncService).not_to receive(:new)

      consumer.consume
    end
  end
end
