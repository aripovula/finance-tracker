require "rails_helper"

RSpec.describe DashboardData do
  describe "#spent_this_month_cents" do
    it "sums this month's monthly_summaries for the user" do
      travel_to monthly_summaries(:one).month + 10.days do
        data = described_class.new(users(:one))

        expect(data.spent_this_month_cents).to eq(monthly_summaries(:one).total_spent_cents)
      end
    end

    it "is zero when there are no summaries for the month" do
      travel_to monthly_summaries(:one).month + 10.days do
        data = described_class.new(users(:two))

        expect(data.spent_this_month_cents).to eq(0)
      end
    end
  end

  describe "#spent_last_month_cents" do
    it "sums last month's monthly_summaries for the user" do
      last_month = monthly_summaries(:one).month - 1.month
      MonthlySummary.create!(user: users(:one), category: categories(:restaurants), month: last_month, total_spent_cents: 2000)

      travel_to monthly_summaries(:one).month + 10.days do
        data = described_class.new(users(:one))

        expect(data.spent_last_month_cents).to eq(2000)
      end
    end
  end

  describe "#total_budget_cents, #budget_remaining_cents, #budget_used_pct" do
    it "sums this month's budgets and computes remaining/used" do
      travel_to budgets(:one).effective_month + 10.days do
        data = described_class.new(users(:one))
        expected_total = budgets(:one).monthly_limit_cents + budgets(:two).monthly_limit_cents

        expect(data.total_budget_cents).to eq(expected_total)
        expect(data.budget_remaining_cents).to eq(expected_total - data.spent_this_month_cents)
        expect(data.budget_used_pct).to eq((data.spent_this_month_cents / expected_total.to_f) * 100)
      end
    end

    it "returns nil budget_used_pct when there is no budget for the month" do
      travel_to budgets(:one).effective_month + 10.days do
        data = described_class.new(users(:two))

        expect(data.total_budget_cents).to eq(0)
        expect(data.budget_used_pct).to be_nil
      end
    end
  end

  describe "#over_budget_budgets" do
    it "returns budgets whose monthly_summary total exceeds the limit" do
      MonthlySummary.create!(
        user: users(:one), category: categories(:restaurants), month: budgets(:two).effective_month,
        total_spent_cents: budgets(:two).monthly_limit_cents + 1
      )

      travel_to budgets(:one).effective_month + 10.days do
        data = described_class.new(users(:one))

        expect(data.over_budget_budgets).to contain_exactly(budgets(:two))
      end
    end

    it "returns an empty array when nothing is over budget" do
      travel_to budgets(:one).effective_month + 10.days do
        data = described_class.new(users(:one))

        expect(data.over_budget_budgets).to be_empty
      end
    end
  end

  describe "#invested_this_month_cents, #invested_last_month_cents" do
    it "sums posted, positive-amount transactions in the investment category for each month" do
      Transaction.create!(
        bank_account: bank_accounts(:one), plaid_transaction_id: "txn-invest-this",
        category: categories(:investment_funds), status: "posted", amount_cents: 65_000,
        posted_at: Date.new(2026, 9, 12)
      )
      Transaction.create!(
        bank_account: bank_accounts(:one), plaid_transaction_id: "txn-invest-last",
        category: categories(:investment_funds), status: "posted", amount_cents: 60_000,
        posted_at: Date.new(2026, 8, 12)
      )
      # excluded: pending, and a different category
      Transaction.create!(
        bank_account: bank_accounts(:one), plaid_transaction_id: "txn-invest-pending",
        category: categories(:investment_funds), status: "pending", amount_cents: 99_999,
        posted_at: Date.new(2026, 9, 15)
      )

      travel_to Date.new(2026, 9, 20) do
        data = described_class.new(users(:one))

        expect(data.invested_this_month_cents).to eq(65_000)
        expect(data.invested_last_month_cents).to eq(60_000)
      end
    end
  end
end
