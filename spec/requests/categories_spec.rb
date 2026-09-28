require "rails_helper"

RSpec.describe "Categories", type: :request do
  describe "GET /categories" do
    it "redirects to login when logged out" do
      get categories_path

      expect(response).to redirect_to(login_path)
    end

    it "renders the categories page when logged in" do
      post login_path, params: { email: users(:one).email, password: "password123" }

      get categories_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(categories(:dining).name)
      expect(response.body).to include(categories(:restaurants).name)
      expect(response.body).to include("How this works")
    end
  end
end
