require "swagger_helper"

RSpec.describe "api/v1/categories", type: :request do
  path "/api/v1/categories" do
    get "Lists all categories" do
      tags "Categories"
      security [ bearerAuth: [] ]
      produces "application/json"
      parameter name: :Authorization, in: :header, type: :string, required: true

      response "200", "categories listed" do
        let(:Authorization) { "Bearer #{AuthTokenService.new.issue_tokens(users(:one))[:access_token]}" }

        run_test! do |response|
          data = JSON.parse(response.body)["data"]
          expect(data.map { |category| category["name"] }).to contain_exactly(
            "Dining", "Restaurants", "Investment And Retirement Funds", "Account Transfer",
            "Credit Card Payment", "Interest Earned"
          )
        end
      end

      response "401", "missing or invalid token" do
        let(:Authorization) { "Bearer not-a-real-token" }

        run_test!
      end
    end
  end
end
