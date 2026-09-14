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

  path "/api/v1/plaid/exchange_public_token" do
    post "Exchanges a Plaid public_token and creates a bank_account" do
      tags "Plaid"
      consumes "application/json"
      produces "application/json"
      parameter name: :body, in: :body, schema: {
        type: :object,
        properties: {
          user_id: { type: :integer },
          public_token: { type: :string },
          institution_name: { type: :string },
          account_id: { type: :string },
          mask: { type: :string }
        },
        required: [ "user_id", "public_token", "institution_name", "account_id" ]
      }

      response "201", "bank_account created" do
        let(:body) do
          {
            user_id: users(:one).id,
            public_token: "public-sandbox-123",
            institution_name: "Chase",
            account_id: "account-sandbox-new",
            mask: "4321"
          }
        end

        before do
          fake_response = instance_double(Plaid::ItemPublicTokenExchangeResponse, access_token: "access-sandbox-123", item_id: "item-sandbox-123")
          fake_client = instance_double(Plaid::PlaidApi, item_public_token_exchange: fake_response)
          allow(PlaidClient).to receive(:client).and_return(fake_client)
        end

        run_test! do |response|
          data = JSON.parse(response.body)["data"]["bank_account"]
          expect(data["institution_name"]).to eq("Chase")
        end
      end

      response "404", "user not found" do
        let(:body) { { user_id: 0, public_token: "public-sandbox-123", institution_name: "Chase", account_id: "account-sandbox-new" } }

        run_test!
      end

      response "422", "duplicate plaid_account_id" do
        let(:body) do
          {
            user_id: users(:one).id,
            public_token: "public-sandbox-123",
            institution_name: "Chase",
            account_id: bank_accounts(:one).plaid_account_id
          }
        end

        before do
          fake_response = instance_double(Plaid::ItemPublicTokenExchangeResponse, access_token: "access-sandbox-123", item_id: "item-sandbox-123")
          fake_client = instance_double(Plaid::PlaidApi, item_public_token_exchange: fake_response)
          allow(PlaidClient).to receive(:client).and_return(fake_client)
        end

        run_test!
      end
    end
  end
end
