require "digest"

class PlaidWebhookVerifier
  Error = Class.new(StandardError)

  MAX_IAT_DRIFT = 5 * 60
  ALGORITHM = "ES256"

  def self.verify!(jwt:, body:)
    new(jwt: jwt, body: body).verify!
  end

  def initialize(jwt:, body:)
    @jwt = jwt
    @body = body
  end

  def verify!
    payload = decode_and_verify_signature
    check_freshness!(payload)
    check_body_hash!(payload)
    true
  end

  private

  def decode_and_verify_signature
    jwk = JWT::JWK::EC.new(verification_key_params(unverified_kid))

    JWT.decode(@jwt, jwk.public_key, true, algorithm: ALGORITHM).first
  rescue JWT::DecodeError => e
    raise Error, "Invalid webhook signature: #{e.message}"
  end

  def unverified_kid
    JWT.decode(@jwt, nil, false).last["kid"]
  rescue JWT::DecodeError
    raise Error, "Malformed webhook JWT"
  end

  def verification_key_params(kid)
    Rails.cache.fetch("plaid_webhook_verification_key/#{kid}", expires_in: 24.hours) do
      request = Plaid::WebhookVerificationKeyGetRequest.new(key_id: kid)
      key = PlaidClient.client.webhook_verification_key_get(request).key

      { "kty" => key.kty, "crv" => key.crv, "x" => key.x, "y" => key.y, "kid" => key.kid }
    end
  end

  def check_freshness!(payload)
    iat = payload["iat"]
    raise Error, "Missing iat claim" unless iat
    raise Error, "Webhook timestamp too old" if Time.now.to_i - iat > MAX_IAT_DRIFT
  end

  def check_body_hash!(payload)
    expected = Digest::SHA256.hexdigest(@body)

    unless ActiveSupport::SecurityUtils.secure_compare(expected, payload["request_body_sha256"].to_s)
      raise Error, "Body hash mismatch"
    end
  end
end
