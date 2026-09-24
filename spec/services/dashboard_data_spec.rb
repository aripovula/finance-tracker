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
    it "sums this month's budgets and computes remaining/used from budgeted categories only" do
      # Spend in a category with no budget must not affect remaining/used - only
      # spend within budgeted categories (dining, restaurants) counts.
      MonthlySummary.create!(
        user: users(:one), category: categories(:account_transfer), month: budgets(:one).effective_month, total_spent_cents: 999_999
      )

      travel_to budgets(:one).effective_month + 10.days do
        data = described_class.new(users(:one))
        expected_total = budgets(:one).monthly_limit_cents + budgets(:two).monthly_limit_cents
        expected_spent = monthly_summaries(:one).total_spent_cents

        expect(data.total_budget_cents).to eq(expected_total)
        expect(data.budget_remaining_cents).to eq(expected_total - expected_spent)
        expect(data.budget_used_pct).to eq((expected_spent / expected_total.to_f) * 100)
      end
    end

    it "returns nil budget_used_pct when there is no budget for the month" do
      travel_to budgets(:one).effective_month + 10.days do
        data = described_class.new(users(:two))

        expect(data.total_budget_cents).to eq(0)
        expect(data.budget_used_pct).to be_nil
      end
    end

    it "folds in trailing-average fallback categories that have no user budget" do
      month = budgets(:one).effective_month
      MonthlySummary.create!(user: users(:one), category: categories(:account_transfer), month: month, total_spent_cents: 12_000)
      MonthlySummary.create!(user: users(:one), category: categories(:account_transfer), month: month - 1.month, total_spent_cents: 9_000)
      MonthlySummary.create!(user: users(:one), category: categories(:account_transfer), month: month - 2.months, total_spent_cents: 3_000)

      travel_to month + 10.days do
        data = described_class.new(users(:one))
        budgeted_total = budgets(:one).monthly_limit_cents + budgets(:two).monthly_limit_cents

        expect(data.total_budget_cents).to eq(budgeted_total + 4_000) # (9_000 + 3_000 + 0) / 3
      end
    end
  end

  describe "#trailing_average_cents" do
    it "averages total_spent_cents over the trailing N months, treating missing months as zero" do
      month = budgets(:one).effective_month
      MonthlySummary.create!(user: users(:one), category: categories(:account_transfer), month: month - 1.month, total_spent_cents: 9_000)
      MonthlySummary.create!(user: users(:one), category: categories(:account_transfer), month: month - 2.months, total_spent_cents: 3_000)
      # month - 3.months has no summary, counted as zero

      data = described_class.new(users(:one), month: month)

      expect(data.trailing_average_cents(categories(:account_transfer))).to eq(4_000)
    end
  end

  describe "#over_budget_comparisons" do
    it "returns comparisons whose spend exceeds their budget" do
      MonthlySummary.create!(
        user: users(:one), category: categories(:restaurants), month: budgets(:two).effective_month,
        total_spent_cents: budgets(:two).monthly_limit_cents + 1
      )

      travel_to budgets(:one).effective_month + 10.days do
        data = described_class.new(users(:one))

        expect(data.over_budget_comparisons.map { |c| c[:category_name] }).to contain_exactly(categories(:restaurants).name)
      end
    end

    it "includes trailing-average fallback categories that are over their average" do
      month = budgets(:one).effective_month
      MonthlySummary.create!(user: users(:one), category: categories(:account_transfer), month: month, total_spent_cents: 12_000)
      MonthlySummary.create!(user: users(:one), category: categories(:account_transfer), month: month - 1.month, total_spent_cents: 9_000)
      MonthlySummary.create!(user: users(:one), category: categories(:account_transfer), month: month - 2.months, total_spent_cents: 3_000)

      travel_to month + 10.days do
        data = described_class.new(users(:one))

        expect(data.over_budget_comparisons.map { |c| c[:category_name] }).to include("#{categories(:account_transfer).name} (avg)")
      end
    end

    it "returns an empty array when nothing is over budget" do
      travel_to budgets(:one).effective_month + 10.days do
        data = described_class.new(users(:one))

        expect(data.over_budget_comparisons).to be_empty
      end
    end
  end

  describe "#budget_comparisons" do
    it "computes spend, delta percent, and status per budget" do
      MonthlySummary.create!(
        user: users(:one), category: categories(:restaurants), month: budgets(:two).effective_month, total_spent_cents: 21_000
      )

      travel_to budgets(:one).effective_month + 10.days do
        data = described_class.new(users(:one))
        comparisons = data.budget_comparisons

        dining = comparisons.find { |c| c[:category_name] == categories(:dining).name }
        restaurants = comparisons.find { |c| c[:category_name] == categories(:restaurants).name }

        expect(dining[:spent_cents]).to eq(monthly_summaries(:one).total_spent_cents)
        expect(dining[:status]).to eq(:good)

        expect(restaurants[:spent_cents]).to eq(21_000)
        expect(restaurants[:delta_pct]).to be_within(0.1).of(5.0)
        expect(restaurants[:status]).to eq(:warning)
      end
    end

    it "marks a budget critical when spend is 15% or more over the limit" do
      MonthlySummary.create!(
        user: users(:one), category: categories(:restaurants), month: budgets(:two).effective_month, total_spent_cents: 25_000
      )

      travel_to budgets(:one).effective_month + 10.days do
        data = described_class.new(users(:one))
        restaurants = data.budget_comparisons.find { |c| c[:category_name] == categories(:restaurants).name }

        expect(restaurants[:status]).to eq(:critical)
      end
    end

    it "falls back to the trailing 3-month average when there is no user budget" do
      month = budgets(:one).effective_month
      MonthlySummary.create!(user: users(:one), category: categories(:account_transfer), month: month, total_spent_cents: 12_000)
      MonthlySummary.create!(user: users(:one), category: categories(:account_transfer), month: month - 1.month, total_spent_cents: 9_000)
      MonthlySummary.create!(user: users(:one), category: categories(:account_transfer), month: month - 2.months, total_spent_cents: 3_000)

      travel_to month + 10.days do
        data = described_class.new(users(:one))
        transfer = data.budget_comparisons.find { |c| c[:category_name] == "#{categories(:account_transfer).name} (avg)" }

        expect(transfer[:spent_cents]).to eq(12_000)
        expect(transfer[:budget_cents]).to eq(4_000)
      end
    end

    it "excludes a category with spend but no budget and no trailing history" do
      month = budgets(:one).effective_month
      MonthlySummary.create!(user: users(:one), category: categories(:account_transfer), month: month, total_spent_cents: 12_000)

      travel_to month + 10.days do
        data = described_class.new(users(:one))

        expect(data.budget_comparisons.map { |c| c[:category_name] }).not_to include("#{categories(:account_transfer).name} (avg)")
      end
    end

    it "sorts by the size of the deviation, largest first" do
      MonthlySummary.create!(
        user: users(:one), category: categories(:restaurants), month: budgets(:two).effective_month, total_spent_cents: 21_000
      )

      travel_to budgets(:one).effective_month + 10.days do
        data = described_class.new(users(:one))
        deltas = data.budget_comparisons.map { |c| c[:delta_pct].abs }

        expect(deltas).to eq(deltas.sort.reverse)
      end
    end
  end

  describe "#category_breakdown" do
    it "folds categories beyond the top 5 into Other" do
      month = monthly_summaries(:one).month # dining: 4599

      extra_categories = (1..5).map { |i| Category.create!(name: "Extra #{i}", plaid_category_id: "EXTRA_#{i}") }
      extra_categories.each_with_index do |category, i|
        MonthlySummary.create!(user: users(:one), category: category, month: month, total_spent_cents: (i + 1) * 1000)
      end

      travel_to month + 10.days do
        data = described_class.new(users(:one))
        breakdown = data.category_breakdown(months_count: 1)

        expect(breakdown[:series_names]).to include("Other")
        expect(breakdown[:series_names].size).to eq(6)
        expect(breakdown[:rows].size).to eq(1)
        expect(breakdown[:rows].first[:month]).to eq(month)
      end
    end

    it "returns one row per month with per-series totals aligned to series_names" do
      travel_to monthly_summaries(:one).month + 10.days do
        data = described_class.new(users(:one))
        breakdown = data.category_breakdown(months_count: 3)

        expect(breakdown[:rows].size).to eq(3)
        dining_index = breakdown[:series_names].index(categories(:dining).name)
        expect(breakdown[:rows].last[:values][dining_index]).to eq(monthly_summaries(:one).total_spent_cents)
      end
    end
  end

  describe "#spend_trend" do
    it "returns one point per trailing month, defaulting missing months to zero" do
      travel_to monthly_summaries(:one).month + 10.days do
        data = described_class.new(users(:one))
        trend = data.spend_trend(months_count: 3)

        expect(trend.size).to eq(3)
        expect(trend.map { |point| point[:month] }).to eq(trend.map { |point| point[:month] }.sort)
        expect(trend.last[:month]).to eq(monthly_summaries(:one).month)
        expect(trend.last[:total_spent_cents]).to eq(monthly_summaries(:one).total_spent_cents)
        expect(trend.first[:total_spent_cents]).to eq(0)
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

    it "also counts CD deposits filed under the generic account-transfer category" do
      Transaction.create!(
        bank_account: bank_accounts(:one), plaid_transaction_id: "txn-cd-deposit",
        category: categories(:account_transfer), status: "posted", amount_cents: 100_000,
        posted_at: Date.new(2026, 9, 11), merchant_name: "CD DEPOSIT .INITIAL."
      )
      # excluded: a same-category transfer that isn't a CD deposit (e.g. payroll)
      Transaction.create!(
        bank_account: bank_accounts(:one), plaid_transaction_id: "txn-payroll",
        category: categories(:account_transfer), status: "posted", amount_cents: 585_000,
        posted_at: Date.new(2026, 9, 11), merchant_name: "ACH Electronic CreditGUSTO PAY 123456"
      )

      travel_to Date.new(2026, 9, 20) do
        data = described_class.new(users(:one))

        expect(data.invested_this_month_cents).to eq(100_000)
      end
    end
  end

  describe "#recent_investment_transactions" do
    it "returns posted, positive-amount investment transactions, most recent first, limited" do
      older = Transaction.create!(
        bank_account: bank_accounts(:one), plaid_transaction_id: "txn-invest-older",
        category: categories(:investment_funds), status: "posted", amount_cents: 10_000,
        posted_at: Date.new(2026, 9, 1), merchant_name: "CD DEPOSIT .INITIAL."
      )
      newer = Transaction.create!(
        bank_account: bank_accounts(:one), plaid_transaction_id: "txn-invest-newer",
        category: categories(:investment_funds), status: "posted", amount_cents: 20_000,
        posted_at: Date.new(2026, 9, 15), merchant_name: "TRANSFER TO BROKERAGE"
      )
      # excluded: pending status
      Transaction.create!(
        bank_account: bank_accounts(:one), plaid_transaction_id: "txn-invest-pending2",
        category: categories(:investment_funds), status: "pending", amount_cents: 30_000,
        posted_at: Date.new(2026, 9, 16)
      )

      data = described_class.new(users(:one))

      expect(data.recent_investment_transactions(limit: 2)).to eq([ newer, older ])
    end

    it "includes CD deposits filed under the generic account-transfer category" do
      cd_deposit = Transaction.create!(
        bank_account: bank_accounts(:one), plaid_transaction_id: "txn-cd-deposit-recent",
        category: categories(:account_transfer), status: "posted", amount_cents: 100_000,
        posted_at: Date.new(2026, 9, 11), merchant_name: "CD DEPOSIT .INITIAL."
      )

      data = described_class.new(users(:one))

      expect(data.recent_investment_transactions).to include(cd_deposit)
    end
  end
end
