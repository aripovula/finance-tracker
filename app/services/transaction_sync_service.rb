class TransactionSyncService
  def call(bank_account)
    loop do
      response = fetch_page(bank_account)

      upsert_transactions(bank_account, response.added + response.modified)
      remove_transactions(response.removed)

      bank_account.update!(plaid_cursor: response.next_cursor)

      break unless response.has_more
    end
  end

  private

  def fetch_page(bank_account)
    request = Plaid::TransactionsSyncRequest.new(
      access_token: bank_account.plaid_access_token,
      cursor: bank_account.plaid_cursor
    )

    PlaidClient.client.transactions_sync(request)
  end

  def upsert_transactions(bank_account, plaid_transactions)
    plaid_transactions.each do |plaid_transaction|
      transaction = Transaction.find_or_initialize_by(plaid_transaction_id: plaid_transaction.transaction_id)

      transaction.update!(
        bank_account: bank_account,
        amount_cents: (plaid_transaction.amount.to_f * 100).round,
        merchant_name: plaid_transaction.merchant_name || plaid_transaction.name,
        posted_at: plaid_transaction.datetime || plaid_transaction.date,
        status: plaid_transaction.pending ? "pending" : "posted",
        raw_payload: plaid_transaction.to_hash
      )
    end
  end

  def remove_transactions(removed_transactions)
    return if removed_transactions.empty?

    Transaction.where(plaid_transaction_id: removed_transactions.map(&:transaction_id)).destroy_all
  end
end
