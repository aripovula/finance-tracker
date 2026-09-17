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
    it "creates a budget for the current user from a dollar amount and month" do
      post login_path, params: { email: users(:one).email, password: "password123" }

      expect {
        post budgets_path, params: {
          budget: { category_id: categories(:dining).id, monthly_limit: "300.00", effective_month: "2026-10" }
        }
      }.to change { users(:one).budgets.count }.by(1)

      expect(response).to redirect_to(budgets_path)
      created = users(:one).budgets.order(:created_at).last
      expect(created.monthly_limit_cents).to eq(30_000)
      expect(created.effective_month).to eq(Date.new(2026, 10, 1))
    end

    it "re-renders the form with errors on invalid params" do
      post login_path, params: { email: users(:one).email, password: "password123" }

      post budgets_path, params: {
        budget: { category_id: categories(:dining).id, monthly_limit: "300.00", effective_month: budgets(:one).effective_month.strftime("%Y-%m") }
      }

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "PATCH /budgets/:id" do
    it "updates the current user's budget" do
      post login_path, params: { email: users(:one).email, password: "password123" }

      patch budget_path(budgets(:one)), params: {
        budget: {
          category_id: budgets(:one).category_id,
          monthly_limit: "750.00",
          effective_month: budgets(:one).effective_month.strftime("%Y-%m")
        }
      }

      expect(response).to redirect_to(budgets_path)
      expect(budgets(:one).reload.monthly_limit_cents).to eq(75_000)
    end

    it "redirects with an alert when the budget belongs to another user" do
      post login_path, params: { email: users(:two).email, password: "password123" }

      patch budget_path(budgets(:one)), params: {
        budget: {
          category_id: budgets(:one).category_id,
          monthly_limit: "750.00",
          effective_month: budgets(:one).effective_month.strftime("%Y-%m")
        }
      }

      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to be_present
    end
  end

  describe "DELETE /budgets/:id" do
    it "deletes the current user's budget" do
      post login_path, params: { email: users(:one).email, password: "password123" }

      expect {
        delete budget_path(budgets(:one))
      }.to change { users(:one).budgets.count }.by(-1)

      expect(response).to redirect_to(budgets_path)
    end

    it "redirects with an alert when the budget belongs to another user" do
      post login_path, params: { email: users(:two).email, password: "password123" }

      expect {
        delete budget_path(budgets(:one))
      }.not_to change { Budget.count }

      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to be_present
    end
  end
end
