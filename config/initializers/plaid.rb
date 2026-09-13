require "plaid"

module PlaidClient
  def self.client
    @client ||= Plaid::PlaidApi.new(api_client)
  end

  def self.api_client
    configuration = Plaid::Configuration.new
    configuration.server_index = Plaid::Configuration::Environment.fetch(environment)
    configuration.api_key["PLAID-CLIENT-ID"] = client_id
    configuration.api_key["PLAID-SECRET"] = secret

    Plaid::ApiClient.new(configuration)
  end

  def self.client_id
    Rails.application.credentials.dig(:plaid, :client_id) || ENV["PLAID_CLIENT_ID"]
  end

  def self.secret
    Rails.application.credentials.dig(:plaid, :secret) || ENV["PLAID_SECRET"]
  end

  def self.environment
    Rails.application.credentials.dig(:plaid, :env) || ENV["PLAID_ENV"] || "sandbox"
  end
end
