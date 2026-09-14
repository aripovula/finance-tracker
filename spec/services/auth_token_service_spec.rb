require "rails_helper"

RSpec.describe AuthTokenService do
  describe "#issue_tokens" do
    it "creates a refresh token record for the user" do
      expect {
        described_class.new.issue_tokens(users(:one))
      }.to change { users(:one).refresh_tokens.count }.by(1)
    end

    it "returns an access_token that decodes to the user's id" do
      tokens = described_class.new.issue_tokens(users(:one))

      expect(JsonWebToken.decode(tokens[:access_token])[:user_id]).to eq(users(:one).id)
    end

    it "returns a refresh_token matching the stored digest" do
      tokens = described_class.new.issue_tokens(users(:one))

      stored = users(:one).refresh_tokens.order(:created_at).last
      expect(stored.token_digest).to eq(RefreshToken.digest(tokens[:refresh_token]))
    end
  end
end
