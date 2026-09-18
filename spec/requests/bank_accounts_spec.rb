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
end
