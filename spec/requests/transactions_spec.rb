require "rails_helper"

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
    end

    it "does not include another user's transactions" do
      post login_path, params: { email: users(:two).email, password: "password123" }

      get transactions_path

      expect(response.body).not_to include(transactions(:one).merchant_name)
    end
  end
end
