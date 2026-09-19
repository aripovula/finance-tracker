require "swagger_helper"

RSpec.describe "api/v1/webhooks", type: :request do
  path "/api/v1/webhooks/plaid" do
    post "Receives a Plaid webhook" do
      tags "Webhooks"
      consumes "application/json"
      produces "application/json"
      parameter name: "Plaid-Verification", in: :header, type: :string, required: true
      parameter name: :body, in: :body, schema: { type: :object }

      response "200", "webhook accepted and published to Kafka" do
        let(:ec_key) { OpenSSL::PKey::EC.generate("prime256v1") }
        let(:jwk) { JWT::JWK::EC.new(ec_key) }
        let(:body) { { webhook_type: "TRANSACTIONS", webhook_code: "DEFAULT_UPDATE" } }
        let(:"Plaid-Verification") do
          payload = { iat: Time.now.to_i, request_body_sha256: Digest::SHA256.hexdigest(body.to_json) }
          JWT.encode(payload, ec_key, "ES256", kid: jwk.kid)
        end

        before do
          jwk_key = instance_double(
            Plaid::JWKPublicKey,
            kty: jwk.export[:kty], crv: jwk.export[:crv], x: jwk.export[:x], y: jwk.export[:y], kid: jwk.kid
          )
          key_response = instance_double(Plaid::WebhookVerificationKeyGetResponse, key: jwk_key)
          fake_client = instance_double(Plaid::PlaidApi, webhook_verification_key_get: key_response)
          allow(PlaidClient).to receive(:client).and_return(fake_client)
          allow(Karafka.producer).to receive(:produce_async)
        end

        run_test! do
          expect(Karafka.producer).to have_received(:produce_async).with(
            topic: "plaid_webhook_events", payload: body.to_json
          )
        end
      end

      response "401", "invalid webhook signature" do
        let(:"Plaid-Verification") { "not-a-real-jwt" }
        let(:body) { { webhook_type: "TRANSACTIONS" } }

        run_test!
      end
    end
  end
end
