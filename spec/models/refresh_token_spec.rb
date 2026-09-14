require "rails_helper"

RSpec.describe RefreshToken, type: :model do
  it "belongs to a user" do
    expect(refresh_tokens(:one).user).to eq(users(:one))
  end

  it "is invalid without a user" do
    refresh_token = RefreshToken.new(refresh_tokens_attributes.merge(user: nil))
    expect(refresh_token).not_to be_valid
  end

  it "is invalid without a token_digest" do
    refresh_token = RefreshToken.new(refresh_tokens_attributes.merge(token_digest: nil))
    expect(refresh_token).not_to be_valid
  end

  it "is invalid with a duplicate token_digest" do
    refresh_token = RefreshToken.new(refresh_tokens_attributes.merge(token_digest: refresh_tokens(:one).token_digest))
    expect(refresh_token).not_to be_valid
  end

  it "is invalid without an expires_at" do
    refresh_token = RefreshToken.new(refresh_tokens_attributes.merge(expires_at: nil))
    expect(refresh_token).not_to be_valid
  end

  describe ".digest" do
    it "returns a consistent SHA256 hex digest for the same input" do
      expect(described_class.digest("raw-token")).to eq(described_class.digest("raw-token"))
      expect(described_class.digest("raw-token")).not_to eq("raw-token")
    end
  end

  describe "#expired?" do
    it "is false for a token that has not expired" do
      expect(refresh_tokens(:one)).not_to be_expired
    end

    it "is true for a token past its expires_at" do
      refresh_token = RefreshToken.new(refresh_tokens_attributes.merge(expires_at: 1.day.ago))
      expect(refresh_token).to be_expired
    end
  end

  describe "#revoked?" do
    it "is false without a revoked_at" do
      expect(refresh_tokens(:one)).not_to be_revoked
    end

    it "is true with a revoked_at" do
      expect(refresh_tokens(:two)).to be_revoked
    end
  end

  describe "#revoke!" do
    it "sets revoked_at" do
      refresh_token = refresh_tokens(:one)
      refresh_token.revoke!
      expect(refresh_token.reload).to be_revoked
    end
  end

  describe ".active" do
    it "only includes unrevoked, unexpired tokens" do
      expect(RefreshToken.active).to contain_exactly(refresh_tokens(:one))
    end
  end

  def refresh_tokens_attributes
    {
      user: users(:one),
      token_digest: "digest-sandbox-3",
      expires_at: 30.days.from_now
    }
  end
end
