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

  describe "#refresh" do
    it "revokes the used refresh token and issues a new pair" do
      original_tokens = described_class.new.issue_tokens(users(:one))
      original_record = users(:one).refresh_tokens.find_by(token_digest: RefreshToken.digest(original_tokens[:refresh_token]))

      new_tokens = described_class.new.refresh(original_tokens[:refresh_token])

      expect(original_record.reload).to be_revoked
      expect(new_tokens[:refresh_token]).not_to eq(original_tokens[:refresh_token])
      expect(JsonWebToken.decode(new_tokens[:access_token])[:user_id]).to eq(users(:one).id)
    end

    it "raises for an unknown refresh token" do
      expect {
        described_class.new.refresh("not-a-real-token")
      }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "raises when reusing an already-rotated refresh token" do
      original_tokens = described_class.new.issue_tokens(users(:one))
      described_class.new.refresh(original_tokens[:refresh_token])

      expect {
        described_class.new.refresh(original_tokens[:refresh_token])
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
