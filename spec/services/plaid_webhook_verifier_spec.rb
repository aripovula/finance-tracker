require "rails_helper"

RSpec.describe PlaidWebhookVerifier do
  let(:ec_key) { OpenSSL::PKey::EC.generate("prime256v1") }
  let(:jwk) { JWT::JWK::EC.new(ec_key) }
  let(:body) { '{"webhook_type":"TRANSACTIONS","webhook_code":"DEFAULT_UPDATE"}' }

  def build_jwt(key, iat: Time.now.to_i, body_for_hash: body, kid: jwk.kid)
    payload = { iat: iat, request_body_sha256: Digest::SHA256.hexdigest(body_for_hash) }

    JWT.encode(payload, key, "ES256", kid: kid)
  end

  before do
    jwk_key = instance_double(
      Plaid::JWKPublicKey,
      kty: jwk.export[:kty], crv: jwk.export[:crv], x: jwk.export[:x], y: jwk.export[:y], kid: jwk.kid
    )
    response = instance_double(Plaid::WebhookVerificationKeyGetResponse, key: jwk_key)
    fake_client = instance_double(Plaid::PlaidApi, webhook_verification_key_get: response)
    allow(PlaidClient).to receive(:client).and_return(fake_client)
  end

  it "verifies a validly signed, fresh webhook" do
    expect(described_class.verify!(jwt: build_jwt(ec_key), body: body)).to be true
  end

  it "raises for a stale iat" do
    stale_jwt = build_jwt(ec_key, iat: 10.minutes.ago.to_i)

    expect { described_class.verify!(jwt: stale_jwt, body: body) }
      .to raise_error(PlaidWebhookVerifier::Error, /too old/)
  end

  it "raises for a body hash mismatch" do
    jwt = build_jwt(ec_key, body_for_hash: "a different body")

    expect { described_class.verify!(jwt: jwt, body: body) }
      .to raise_error(PlaidWebhookVerifier::Error, /hash mismatch/)
  end

  it "raises when signed by a different key" do
    other_key = OpenSSL::PKey::EC.generate("prime256v1")
    bad_jwt = build_jwt(other_key)

    expect { described_class.verify!(jwt: bad_jwt, body: body) }
      .to raise_error(PlaidWebhookVerifier::Error, /Invalid webhook signature/)
  end
end
