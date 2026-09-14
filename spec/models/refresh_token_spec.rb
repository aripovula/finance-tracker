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

  def refresh_tokens_attributes
    {
      user: users(:one),
      token_digest: "digest-sandbox-3",
      expires_at: 30.days.from_now
    }
  end
end
