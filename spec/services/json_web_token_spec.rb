require "rails_helper"

RSpec.describe JsonWebToken do
  describe ".encode and .decode" do
    it "round-trips a payload" do
      token = described_class.encode({ user_id: 42 }, expires_in: 5.minutes)

      expect(described_class.decode(token)[:user_id]).to eq(42)
    end

    it "returns nil for an expired token" do
      token = described_class.encode({ user_id: 42 }, expires_in: -5.minutes)

      expect(described_class.decode(token)).to be_nil
    end

    it "returns nil for a malformed token" do
      expect(described_class.decode("not-a-real-token")).to be_nil
    end
  end
end
