require "rails_helper"

RSpec.describe "Budgets", type: :request do
  describe "GET /budgets" do
    it "redirects to login when logged out" do
      get budgets_path

      expect(response).to redirect_to(login_path)
    end

    it "renders the current user's budgets when logged in" do
      post login_path, params: { email: users(:one).email, password: "password123" }

      get budgets_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(categories(:dining).name)
      expect(response.body).to include(categories(:restaurants).name)
    end
  end

  describe "POST /budgets" do
    it "creates a budget for the current user" do
      post login_path, params: { email: users(:one).email, password: "password123" }

      expect {
        post budgets_path, params: {
          budget: { category_id: categories(:dining).id, monthly_limit_cents: 30_000, effective_month: "2026-10-01" }
        }
      }.to change { users(:one).budgets.count }.by(1)

      expect(response).to redirect_to(budgets_path)
    end

    it "re-renders the form with errors on invalid params" do
      post login_path, params: { email: users(:one).email, password: "password123" }

      post budgets_path, params: {
        budget: { category_id: categories(:dining).id, monthly_limit_cents: 30_000, effective_month: budgets(:one).effective_month.to_s }
      }

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
