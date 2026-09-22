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

    it "shows this month's spending by category when a summary exists" do
      travel_to monthly_summaries(:one).month do
        post login_path, params: { email: users(:one).email, password: "password123" }

        get root_path

        expect(response.body).to include(categories(:dining).name)
        expect(response.body).to include("$45.99")
      end
    end

    it "shows an empty state when there is no summary for this month" do
      post login_path, params: { email: users(:two).email, password: "password123" }

      get root_path

      expect(response.body).to include("No spending data yet")
    end
  end
end
