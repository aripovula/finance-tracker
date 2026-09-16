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
end
