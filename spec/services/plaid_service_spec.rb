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
end
