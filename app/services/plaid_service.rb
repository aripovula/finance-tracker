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

  def exchange_public_token(user, public_token, institution_name:, plaid_account_id:, mask: nil)
    request = Plaid::ItemPublicTokenExchangeRequest.new(public_token: public_token)
    response = PlaidClient.client.item_public_token_exchange(request)

    BankAccount.create!(
      user: user,
      plaid_item_id: response.item_id,
      plaid_access_token: response.access_token,
      institution_name: institution_name,
      plaid_account_id: plaid_account_id,
      mask: mask
    )
  end
end
