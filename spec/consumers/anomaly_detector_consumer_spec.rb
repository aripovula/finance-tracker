require "rails_helper"

RSpec.describe AnomalyDetectorConsumer do
  let(:consumer) { described_class.new }
  let(:bank_account) { bank_accounts(:one) }
  let(:category) { categories(:restaurants) }

  def message_with(payload)
    instance_double(Karafka::Messages::Message, payload: payload)
  end

  def webhook_payload
    { "webhook_type" => "TRANSACTIONS", "webhook_code" => "SYNC_UPDATES_AVAILABLE", "item_id" => bank_account.plaid_item_id }
  end

  def create_transaction(**attrs)
    Transaction.create!(
      {
        bank_account: bank_account, plaid_transaction_id: SecureRandom.hex(8),
        category: category, status: "posted"
      }.merge(attrs)
    )
  end

  def seed_history(amount_cents:)
    [ 6, 7, 8 ].each do |month|
      create_transaction(amount_cents: amount_cents, posted_at: Date.new(2026, month, 15))
    end
  end

  it "flags a transaction more than 3x the trailing-3-month average" do
    seed_history(amount_cents: 1000)
    transaction = create_transaction(amount_cents: 3001, posted_at: Date.new(2026, 9, 15))

    consumer.messages = [ message_with(webhook_payload) ]
    consumer.consume

    expect(transaction.reload.flagged_anomaly_at).to be_present
  end

  it "does not flag a transaction at or below 3x the average" do
    seed_history(amount_cents: 1000)
    transaction = create_transaction(amount_cents: 3000, posted_at: Date.new(2026, 9, 15))

    consumer.messages = [ message_with(webhook_payload) ]
    consumer.consume

    expect(transaction.reload.flagged_anomaly_at).to be_nil
  end

  it "does not flag when there isn't enough trailing history" do
    create_transaction(amount_cents: 1000, posted_at: Date.new(2026, 7, 15))
    create_transaction(amount_cents: 1000, posted_at: Date.new(2026, 8, 15))
    transaction = create_transaction(amount_cents: 99_999, posted_at: Date.new(2026, 9, 15))

    consumer.messages = [ message_with(webhook_payload) ]
    consumer.consume

    expect(transaction.reload.flagged_anomaly_at).to be_nil
  end

  it "does not re-evaluate an already-flagged transaction" do
    seed_history(amount_cents: 1000)
    transaction = create_transaction(amount_cents: 3001, posted_at: Date.new(2026, 9, 15))
    already_flagged_at = 1.day.ago
    transaction.update!(flagged_anomaly_at: already_flagged_at)

    consumer.messages = [ message_with(webhook_payload) ]
    consumer.consume

    expect(transaction.reload.flagged_anomaly_at).to be_within(1.second).of(already_flagged_at)
  end

  it "does nothing for non-transactions webhooks" do
    consumer.messages = [ message_with({ "webhook_type" => "ITEM" }) ]

    expect { consumer.consume }.not_to raise_error
  end

  it "does nothing when no bank_account matches the item_id" do
    consumer.messages = [ message_with({ "webhook_type" => "TRANSACTIONS", "item_id" => "unknown-item" }) ]

    expect { consumer.consume }.not_to raise_error
  end
end
