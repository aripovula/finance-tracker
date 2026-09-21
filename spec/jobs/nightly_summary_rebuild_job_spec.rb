require "rails_helper"

RSpec.describe NightlySummaryRebuildJob do
  # Fixture transactions(:one): bank_account one, category dining, amount_cents
  # 2599, posted, posted_at 2026-09-01 -- counts toward every September dining
  # total below unless a test specifically targets a different month/category.
  FIXTURE_SEPTEMBER_DINING_CENTS = 2599

  def create_transaction(**attrs)
    Transaction.create!(
      {
        bank_account: bank_accounts(:one), plaid_transaction_id: SecureRandom.hex(8),
        posted_at: Time.current, status: "posted", amount_cents: 1000
      }.merge(attrs)
    )
  end

  it "sums posted, positive-amount, categorized transactions by user/category/month" do
    create_transaction(category: categories(:dining), amount_cents: 1000, posted_at: Date.new(2026, 9, 5))
    create_transaction(category: categories(:dining), amount_cents: 2500, posted_at: Date.new(2026, 9, 20))
    create_transaction(category: categories(:dining), amount_cents: 4000, posted_at: Date.new(2026, 10, 1))

    described_class.new.perform

    september = MonthlySummary.find_by(user: users(:one), category: categories(:dining), month: Date.new(2026, 9, 1))
    october = MonthlySummary.find_by(user: users(:one), category: categories(:dining), month: Date.new(2026, 10, 1))

    expect(september.total_spent_cents).to eq(FIXTURE_SEPTEMBER_DINING_CENTS + 1000 + 2500)
    expect(october.total_spent_cents).to eq(4000)
  end

  it "excludes pending transactions" do
    create_transaction(category: categories(:dining), amount_cents: 9999, status: "pending", posted_at: Date.new(2026, 9, 5))

    described_class.new.perform

    september = MonthlySummary.find_by(user: users(:one), category: categories(:dining), month: Date.new(2026, 9, 1))
    expect(september.total_spent_cents).to eq(FIXTURE_SEPTEMBER_DINING_CENTS)
  end

  it "excludes credits (negative amounts)" do
    create_transaction(category: categories(:dining), amount_cents: -5000, posted_at: Date.new(2026, 9, 5))

    described_class.new.perform

    september = MonthlySummary.find_by(user: users(:one), category: categories(:dining), month: Date.new(2026, 9, 1))
    expect(september.total_spent_cents).to eq(FIXTURE_SEPTEMBER_DINING_CENTS)
  end

  it "excludes uncategorized transactions" do
    create_transaction(category: nil, posted_at: Date.new(2026, 9, 5))

    described_class.new.perform

    expect(MonthlySummary.count).to eq(1) # just the fixture-backed September dining summary
  end

  it "removes stale summaries that no longer have matching transactions" do
    stale = MonthlySummary.create!(user: users(:one), category: categories(:dining), month: Date.new(2020, 1, 1), total_spent_cents: 999)

    described_class.new.perform

    expect(MonthlySummary.exists?(stale.id)).to be false
  end
end
