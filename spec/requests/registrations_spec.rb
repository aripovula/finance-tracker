require "rails_helper"

RSpec.describe "Registrations", type: :request do
  describe "POST /signup" do
    it "creates a new user and redirects to the login page" do
      expect {
        post signup_path, params: { user: { email: "newperson", password: "supersecret1" } }
      }.to change(User, :count).by(1)

      expect(response).to redirect_to(login_path)
      expect(User.find_by(email: "newperson")).to be_present
    end

    it "re-renders the form when the username is already taken" do
      expect {
        post signup_path, params: { user: { email: users(:one).email, password: "supersecret1" } }
      }.not_to change(User, :count)

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "re-renders the form when the password is blank" do
      expect {
        post signup_path, params: { user: { email: "someoneelse", password: "" } }
      }.not_to change(User, :count)

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
