require "rails_helper"

RSpec.describe PlaidService do
  describe "#create_link_token" do
    it "returns the link_token from Plaid" do
      response = instance_double(Plaid::LinkTokenCreateResponse, link_token: "link-sandbox-123")
      plaid_client = instance_double(Plaid::PlaidApi, link_token_create: response)
      allow(PlaidClient).to receive(:client).and_return(plaid_client)

      link_token = described_class.new.create_link_token(users(:one))

      expect(link_token).to eq("link-sandbox-123")
      expect(plaid_client).to have_received(:link_token_create) do |request|
        expect(request.user.client_user_id).to eq(users(:one).id.to_s)
      end
    end
  end

  describe "#exchange_public_token" do
    it "creates a bank_account from the exchange response" do
      response = instance_double(Plaid::ItemPublicTokenExchangeResponse, access_token: "access-sandbox-123", item_id: "item-sandbox-123")
      plaid_client = instance_double(Plaid::PlaidApi, item_public_token_exchange: response)
      allow(PlaidClient).to receive(:client).and_return(plaid_client)

      bank_account = described_class.new.exchange_public_token(
        users(:one), "public-sandbox-123",
        institution_name: "Chase", plaid_account_id: "account-sandbox-123", mask: "4321"
      )

      expect(bank_account).to be_persisted
      expect(bank_account.plaid_access_token).to eq("access-sandbox-123")
      expect(bank_account.plaid_item_id).to eq("item-sandbox-123")
      expect(bank_account.institution_name).to eq("Chase")
      expect(plaid_client).to have_received(:item_public_token_exchange) do |request|
        expect(request.public_token).to eq("public-sandbox-123")
      end
    end
  end
end
