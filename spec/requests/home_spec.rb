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
  end
end
