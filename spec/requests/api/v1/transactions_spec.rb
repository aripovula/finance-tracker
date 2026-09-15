require "swagger_helper"

RSpec.describe "api/v1/transactions", type: :request do
  path "/api/v1/transactions" do
    get "Lists the current user's transactions" do
      tags "Transactions"
      security [ bearerAuth: [] ]
      produces "application/json"
      parameter name: :Authorization, in: :header, type: :string, required: true
      parameter name: :category_id, in: :query, type: :integer, required: false
      parameter name: :limit, in: :query, type: :integer, required: false

      response "200", "transactions listed" do
        let(:Authorization) { "Bearer #{AuthTokenService.new.issue_tokens(users(:one))[:access_token]}" }

        run_test! do |response|
          data = JSON.parse(response.body)["data"]
          expect(data.map { |transaction| transaction["id"] })
            .to contain_exactly(transactions(:one).id, transactions(:two).id)
        end
      end

      response "200", "filtered by category_id" do
        let(:Authorization) { "Bearer #{AuthTokenService.new.issue_tokens(users(:one))[:access_token]}" }
        let(:category_id) { categories(:dining).id }

        run_test! do |response|
          data = JSON.parse(response.body)["data"]
          expect(data.map { |transaction| transaction["id"] }).to eq([ transactions(:one).id ])
        end
      end

      response "401", "missing or invalid token" do
        let(:Authorization) { "Bearer not-a-real-token" }

        run_test!
      end
    end
  end
end
