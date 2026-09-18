require "rails_helper"

RSpec.describe "Bank accounts", type: :request do
  describe "GET /bank_accounts" do
    it "redirects to login when logged out" do
      get bank_accounts_path

      expect(response).to redirect_to(login_path)
    end

    it "renders the current user's bank accounts when logged in" do
      post login_path, params: { email: users(:one).email, password: "password123" }

      get bank_accounts_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(bank_accounts(:one).institution_name)
    end
  end

  describe "POST /bank_accounts/link_token" do
    it "redirects to login when logged out" do
      post link_token_bank_accounts_path

      expect(response).to redirect_to(login_path)
    end

    it "returns a link_token when logged in" do
      post login_path, params: { email: users(:one).email, password: "password123" }

      fake_response = instance_double(Plaid::LinkTokenCreateResponse, link_token: "link-sandbox-123")
      fake_client = instance_double(Plaid::PlaidApi, link_token_create: fake_response)
      allow(PlaidClient).to receive(:client).and_return(fake_client)

      post link_token_bank_accounts_path

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["link_token"]).to eq("link-sandbox-123")
    end
  end

  describe "POST /bank_accounts" do
    it "creates a bank_account for the current user" do
      post login_path, params: { email: users(:one).email, password: "password123" }

      fake_response = instance_double(Plaid::ItemPublicTokenExchangeResponse, access_token: "access-sandbox-123", item_id: "item-sandbox-123")
      fake_client = instance_double(Plaid::PlaidApi, item_public_token_exchange: fake_response)
      allow(PlaidClient).to receive(:client).and_return(fake_client)

      expect {
        post bank_accounts_path, params: {
          public_token: "public-sandbox-123", institution_name: "Chase", account_id: "account-sandbox-new", mask: "4321"
        }
      }.to change { users(:one).bank_accounts.count }.by(1)

      expect(response).to have_http_status(:created)
    end

    it "returns errors for a duplicate plaid_account_id" do
      post login_path, params: { email: users(:one).email, password: "password123" }

      fake_response = instance_double(Plaid::ItemPublicTokenExchangeResponse, access_token: "access-sandbox-123", item_id: "item-sandbox-123")
      fake_client = instance_double(Plaid::PlaidApi, item_public_token_exchange: fake_response)
      allow(PlaidClient).to receive(:client).and_return(fake_client)

      post bank_accounts_path, params: {
        public_token: "public-sandbox-123", institution_name: "Chase", account_id: bank_accounts(:one).plaid_account_id
      }

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
