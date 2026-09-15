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

    post "Creates a budget" do
      tags "Budgets"
      security [ bearerAuth: [] ]
      consumes "application/json"
      produces "application/json"
      parameter name: :Authorization, in: :header, type: :string, required: true
      parameter name: :body, in: :body, schema: {
        type: :object,
        properties: {
          category_id: { type: :integer },
          monthly_limit_cents: { type: :integer },
          effective_month: { type: :string }
        },
        required: [ "category_id", "monthly_limit_cents", "effective_month" ]
      }

      response "201", "budget created" do
        let(:Authorization) { "Bearer #{AuthTokenService.new.issue_tokens(users(:two))[:access_token]}" }
        let(:body) { { category_id: categories(:dining).id, monthly_limit_cents: 30_000, effective_month: "2026-10-01" } }

        run_test! do |response|
          data = JSON.parse(response.body)["data"]
          expect(data["monthly_limit_cents"]).to eq(30_000)
        end
      end

      response "422", "duplicate category for effective_month" do
        let(:Authorization) { "Bearer #{AuthTokenService.new.issue_tokens(users(:one))[:access_token]}" }
        let(:body) do
          {
            category_id: categories(:dining).id,
            monthly_limit_cents: 30_000,
            effective_month: budgets(:one).effective_month.to_s
          }
        end

        run_test!
      end
    end
  end
end
