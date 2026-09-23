require "rails_helper"

RSpec.describe "Home", type: :request do
  describe "GET /" do
    it "redirects to login when logged out" do
      get root_path

      expect(response).to redirect_to(login_path)
    end

    it "renders the homepage when logged in" do
      post login_path, params: { email: users(:one).email, password: "password123" }

      get root_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(users(:one).email)
    end

    it "shows the spent-this-month KPI tile" do
      travel_to monthly_summaries(:one).month do
        post login_path, params: { email: users(:one).email, password: "password123" }

        get root_path

        expect(response.body).to include("Spent this month")
        expect(response.body).to include("$45.99")
      end
    end

    it "shows the budget-remaining KPI tile" do
      travel_to budgets(:one).effective_month do
        post login_path, params: { email: users(:one).email, password: "password123" }

        get root_path

        expect(response.body).to include("Budget remaining")
        expect(response.body).to include("used")
      end
    end

    it "shows the invested-this-month KPI tile" do
      Transaction.create!(
        bank_account: bank_accounts(:one), plaid_transaction_id: "txn-invest-kpi",
        category: categories(:investment_funds), status: "posted", amount_cents: 65_000,
        posted_at: Date.new(2026, 9, 12)
      )

      travel_to Date.new(2026, 9, 20) do
        post login_path, params: { email: users(:one).email, password: "password123" }

        get root_path

        expect(response.body).to include("Invested this month")
        expect(response.body).to include("$650.00")
      end
    end

    it "shows the over-budget KPI tile" do
      MonthlySummary.create!(
        user: users(:one), category: categories(:restaurants), month: budgets(:two).effective_month,
        total_spent_cents: budgets(:two).monthly_limit_cents + 1
      )

      travel_to budgets(:one).effective_month do
        post login_path, params: { email: users(:one).email, password: "password123" }

        get root_path

        expect(response.body).to include("Over budget")
        expect(response.body).to include(categories(:restaurants).name)
      end
    end

    it "shows the budget vs. actual chart with cut-back and room-to-spend callouts" do
      MonthlySummary.create!(
        user: users(:one), category: categories(:restaurants), month: budgets(:two).effective_month,
        total_spent_cents: budgets(:two).monthly_limit_cents + 5_000
      )

      travel_to budgets(:one).effective_month do
        post login_path, params: { email: users(:one).email, password: "password123" }

        get root_path

        expect(response.body).to include("Budget vs. actual")
        expect(response.body).to include("Cut back:")
        expect(response.body).to include("Room to spend:")
        expect(response.body).to include(categories(:restaurants).name)
      end
    end

    it "shows the category breakdown chart with a legend when summaries exist" do
      travel_to monthly_summaries(:one).month do
        post login_path, params: { email: users(:one).email, password: "password123" }

        get root_path

        expect(response.body).to include("Spending by category")
        expect(response.body).to include(categories(:dining).name)
      end
    end

    it "shows an empty state when there is no summary data" do
      post login_path, params: { email: users(:two).email, password: "password123" }

      get root_path

      expect(response.body).to include("No spending data yet")
    end

    it "shows the spending trend chart" do
      travel_to monthly_summaries(:one).month do
        post login_path, params: { email: users(:one).email, password: "password123" }

        get root_path

        expect(response.body).to include("Spending trend")
        expect(response.body).to include("Trailing 12 months")
      end
    end

    it "shows recent investment transfers" do
      Transaction.create!(
        bank_account: bank_accounts(:one), plaid_transaction_id: "txn-invest-transfer",
        category: categories(:investment_funds), status: "posted", amount_cents: 65_000,
        posted_at: Date.new(2026, 9, 12), merchant_name: "CD DEPOSIT .INITIAL."
      )

      travel_to Date.new(2026, 9, 20) do
        post login_path, params: { email: users(:one).email, password: "password123" }

        get root_path

        expect(response.body).to include("Investment transfers")
        expect(response.body).to include("CD DEPOSIT .INITIAL.")
        expect(response.body).to include("$650.00")
      end
    end

    it "shows an active budget alert" do
      post login_path, params: { email: users(:one).email, password: "password123" }

      get root_path

      expect(response.body).to include("is over budget this month")
      expect(response.body).to include(categories(:dining).name)
    end

    it "does not show a dismissed budget alert" do
      budget_alerts(:one).update!(dismissed_at: Time.current)
      post login_path, params: { email: users(:one).email, password: "password123" }

      get root_path

      expect(response.body).not_to include("is over budget this month")
    end
  end
end
