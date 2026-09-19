module Api
  module V1
    class WebhooksController < BaseController
      PLAID_TOPIC = "plaid_webhook_events".freeze

      def plaid
        PlaidWebhookVerifier.verify!(jwt: request.headers["Plaid-Verification"], body: request.raw_post)

        Karafka.producer.produce_async(topic: PLAID_TOPIC, payload: request.raw_post)

        render_envelope(status: :ok)
      rescue PlaidWebhookVerifier::Error
        render_envelope(errors: [ "Invalid webhook signature" ], status: :unauthorized)
      end
    end
  end
end
