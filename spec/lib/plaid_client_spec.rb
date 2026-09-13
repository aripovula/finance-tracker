require "rails_helper"

RSpec.describe PlaidClient do
  describe ".client" do
    it "returns a configured Plaid::PlaidApi instance" do
      expect(described_class.client).to be_a(Plaid::PlaidApi)
    end
  end

  describe ".environment" do
    it "defaults to sandbox" do
      expect(described_class.environment).to eq("sandbox")
    end
  end
end
