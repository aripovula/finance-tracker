module TransactionsHelper
  # Plaid's amount sign is the opposite of how people expect to read it: positive
  # means money left the account (a charge), negative means money came in (a
  # credit/refund). Flip it for display so charges read as "-$x" and credits as "+$x".
  def transaction_amount_class(transaction)
    transaction.amount_cents.negative? ? "text-green-600" : "text-gray-900"
  end

  def transaction_amount_label(transaction)
    sign = transaction.amount_cents.negative? ? "+" : "-"
    "#{sign}#{number_to_currency(transaction.amount_cents.abs / 100.0)}"
  end
end
