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
end
