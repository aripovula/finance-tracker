require "rails_helper"
require "csv"

RSpec.describe "Transactions", type: :request do
  describe "GET /transactions" do
    it "redirects to login when logged out" do
      get transactions_path

      expect(response).to redirect_to(login_path)
    end

    it "renders the current user's transactions when logged in" do
      post login_path, params: { email: users(:one).email, password: "password123" }

      get transactions_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(transactions(:one).merchant_name)
      expect(response.body).to include(transactions(:two).merchant_name)
      expect(response.body).to include("How this works")
    end

    it "does not include another user's transactions" do
      post login_path, params: { email: users(:two).email, password: "password123" }

      get transactions_path

      expect(response.body).not_to include(transactions(:one).merchant_name)
    end

    it "shows a charge as a negative amount and a credit as a positive one" do
      credit = Transaction.create!(
        bank_account: bank_accounts(:one), plaid_transaction_id: "txn-credit-1",
        amount_cents: -5000, merchant_name: "Refund Co", posted_at: Time.current, status: "posted"
      )
      post login_path, params: { email: users(:one).email, password: "password123" }

      get transactions_path

      expect(response.body).to include("-$25.99") # transactions(:one), amount_cents: 2599 (a charge)
      expect(response.body).to include("+$50.00") # the credit created above
      expect(credit.amount_cents).to be_negative
    end

    it "shows an Unusual badge for a flagged transaction" do
      transactions(:one).update!(flagged_anomaly_at: Time.current)
      post login_path, params: { email: users(:one).email, password: "password123" }

      get transactions_path

      expect(response.body).to include("Unusual")
    end
  end

  describe "GET /transactions.csv" do
    it "downloads every one of the user's transactions, not just a filtered subset" do
      post login_path, params: { email: users(:one).email, password: "password123" }

      get transactions_path(format: :csv)

      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq("text/csv")

      rows = CSV.parse(response.body, headers: true)
      expect(rows.headers).to eq([ "Merchant", "Category", "Amount", "Status", "Posted" ])
      expect(rows.map { |row| row["Merchant"] }).to contain_exactly(
        transactions(:one).merchant_name, transactions(:two).merchant_name
      )
    end

    it "does not include another user's transactions" do
      post login_path, params: { email: users(:two).email, password: "password123" }

      get transactions_path(format: :csv)

      expect(response.body).not_to include(transactions(:one).merchant_name)
    end

    it "neutralizes a leading formula character in a merchant name" do
      Transaction.create!(
        bank_account: bank_accounts(:one), plaid_transaction_id: "txn-formula-1",
        amount_cents: 100, merchant_name: "=cmd|'/c calc'!A1", posted_at: Time.current, status: "posted"
      )
      post login_path, params: { email: users(:one).email, password: "password123" }

      get transactions_path(format: :csv)

      rows = CSV.parse(response.body, headers: true)
      expect(rows.map { |row| row["Merchant"] }).to include("'=cmd|'/c calc'!A1")
    end
  end

  describe "GET /transactions/:id" do
    it "renders the transaction when it belongs to the current user" do
      post login_path, params: { email: users(:one).email, password: "password123" }

      get transaction_path(transactions(:one))

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(transactions(:one).merchant_name)
    end

    it "shows an Unusual badge when the transaction is flagged" do
      transactions(:one).update!(flagged_anomaly_at: Time.current)
      post login_path, params: { email: users(:one).email, password: "password123" }

      get transaction_path(transactions(:one))

      expect(response.body).to include("Unusual")
    end

    it "redirects with an alert when the transaction belongs to another user" do
      post login_path, params: { email: users(:two).email, password: "password123" }

      get transaction_path(transactions(:one))

      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to be_present
    end
  end
end
