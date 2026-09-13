class PlaidService
  def create_link_token(user)
    request = Plaid::LinkTokenCreateRequest.new(
      client_name: "Finance Tracker",
      language: "en",
      country_codes: [ "US" ],
      user: Plaid::LinkTokenCreateRequestUser.new(client_user_id: user.id.to_s),
      products: [ "transactions" ]
    )

    PlaidClient.client.link_token_create(request).link_token
  end
end
