require "swagger_helper"

RSpec.describe "api/v1/budgets", type: :request do
  path "/api/v1/budgets" do
    get "Lists the current user's budgets" do
      tags "Budgets"
      security [ bearerAuth: [] ]
      produces "application/json"
      parameter name: :Authorization, in: :header, type: :string, required: true

      response "200", "budgets listed" do
        let(:Authorization) { "Bearer #{AuthTokenService.new.issue_tokens(users(:one))[:access_token]}" }

        run_test! do |response|
          data = JSON.parse(response.body)["data"]
          expect(data.map { |budget| budget["id"] }).to contain_exactly(budgets(:one).id, budgets(:two).id)
        end
      end
    end
  end
end
