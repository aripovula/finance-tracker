require "swagger_helper"

RSpec.describe "api/v1/plaid", type: :request do
  path "/api/v1/plaid/link_token" do
    post "Creates a Plaid Link token" do
      tags "Plaid"
      consumes "application/json"
      produces "application/json"
      parameter name: :body, in: :body, schema: {
        type: :object,
        properties: {
          user_id: { type: :integer }
        },
        required: [ "user_id" ]
      }

      response "200", "link token created" do
        let(:body) { { user_id: users(:one).id } }

        before do
          fake_response = instance_double(Plaid::LinkTokenCreateResponse, link_token: "link-sandbox-123")
          fake_client = instance_double(Plaid::PlaidApi, link_token_create: fake_response)
          allow(PlaidClient).to receive(:client).and_return(fake_client)
        end

        run_test! do |response|
          data = JSON.parse(response.body)["data"]
          expect(data["link_token"]).to eq("link-sandbox-123")
        end
      end

      response "404", "user not found" do
        let(:body) { { user_id: 0 } }

        run_test!
      end
    end
  end
end
