require "swagger_helper"

RSpec.describe "api/v1/auth", type: :request do
  path "/api/v1/auth/register" do
    post "Registers a new user" do
      tags "Auth"
      consumes "application/json"
      produces "application/json"
      parameter name: :body, in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string },
          password: { type: :string }
        },
        required: [ "email", "password" ]
      }

      response "201", "user registered" do
        let(:body) { { email: "new-user@example.com", password: "password123" } }

        run_test! do |response|
          data = JSON.parse(response.body)["data"]
          expect(data["access_token"]).to be_present
          expect(data["refresh_token"]).to be_present
        end
      end

      response "422", "invalid params" do
        let(:body) { { email: users(:one).email, password: "password123" } }

        run_test!
      end
    end
  end

  path "/api/v1/auth/login" do
    post "Logs in with email and password" do
      tags "Auth"
      consumes "application/json"
      produces "application/json"
      parameter name: :body, in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string },
          password: { type: :string }
        },
        required: [ "email", "password" ]
      }

      response "200", "logged in" do
        let(:body) { { email: users(:one).email, password: "password123" } }

        run_test! do |response|
          data = JSON.parse(response.body)["data"]
          expect(data["access_token"]).to be_present
          expect(data["refresh_token"]).to be_present
        end
      end

      response "401", "invalid credentials" do
        let(:body) { { email: users(:one).email, password: "wrong-password" } }

        run_test!
      end
    end
  end

  path "/api/v1/auth/refresh" do
    post "Rotates a refresh token for a new token pair" do
      tags "Auth"
      consumes "application/json"
      produces "application/json"
      parameter name: :body, in: :body, schema: {
        type: :object,
        properties: {
          refresh_token: { type: :string }
        },
        required: [ "refresh_token" ]
      }

      response "200", "token pair rotated" do
        let(:body) { { refresh_token: AuthTokenService.new.issue_tokens(users(:one))[:refresh_token] } }

        run_test! do |response|
          data = JSON.parse(response.body)["data"]
          expect(data["access_token"]).to be_present
          expect(data["refresh_token"]).to be_present
        end
      end

      response "401", "invalid refresh token" do
        let(:body) { { refresh_token: "not-a-real-token" } }

        run_test!
      end
    end
  end
end
