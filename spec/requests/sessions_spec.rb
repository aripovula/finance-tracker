require "rails_helper"

RSpec.describe "Sessions", type: :request do
  describe "POST /login" do
    it "logs in with valid credentials and redirects home" do
      post login_path, params: { email: users(:one).email, password: "password123" }

      expect(response).to redirect_to(root_path)
      expect(session[:user_id]).to eq(users(:one).id)
    end

    it "rejects invalid credentials" do
      post login_path, params: { email: users(:one).email, password: "wrongpassword" }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(session[:user_id]).to be_nil
    end
  end
end
