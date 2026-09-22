require "rails_helper"

RSpec.describe BudgetCheckerConsumer do
  let(:consumer) { described_class.new }
  let(:bank_account) { bank_accounts(:one) }
  let(:budget) { budgets(:one) } # dining, monthly_limit_cents: 50_000, effective_month: 2026-09-01

  before { AppRedis.client.flushdb }

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
        category: budget.category, status: "posted", posted_at: budget.effective_month + 10.days
      }.merge(attrs)
    )
  end

  around do |example|
    travel_to(budget.effective_month + 15.days) { example.run }
  end

  it "creates an alert when spending exceeds the budget" do
    create_transaction(amount_cents: budget.monthly_limit_cents + 1)

    expect {
      consumer.messages = [ message_with(webhook_payload) ]
      consumer.consume
    }.to change { BudgetAlert.count }.by(1)

    alert = BudgetAlert.last
    expect(alert.budget).to eq(budget)
    expect(alert.spent_cents).to be > budget.monthly_limit_cents
  end

  it "does not create an alert when under budget" do
    # transactions(:one) fixture already contributes 2599 cents to this budget's category/month
    create_transaction(amount_cents: 1000)

    consumer.messages = [ message_with(webhook_payload) ]

    expect { consumer.consume }.not_to change { BudgetAlert.count }
  end

  it "throttles repeat alerts for the same user/category/day" do
    create_transaction(amount_cents: budget.monthly_limit_cents + 1)

    consumer.messages = [ message_with(webhook_payload) ]
    consumer.consume

    create_transaction(amount_cents: 1000)
    consumer.messages = [ message_with(webhook_payload) ]

    expect { consumer.consume }.not_to change { BudgetAlert.count }
  end

  it "does nothing for non-transactions webhooks" do
    consumer.messages = [ message_with({ "webhook_type" => "ITEM" }) ]

    expect { consumer.consume }.not_to change { BudgetAlert.count }
  end

  it "does nothing when no bank_account matches the item_id" do
    consumer.messages = [ message_with({ "webhook_type" => "TRANSACTIONS", "item_id" => "unknown-item" }) ]

    expect { consumer.consume }.not_to change { BudgetAlert.count }
  end
end
