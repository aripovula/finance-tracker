class AnomalyDetectorConsumer < ApplicationConsumer
  ANOMALY_MULTIPLIER = 3
  MIN_HISTORY_COUNT = 3
  LOOKBACK_MONTHS = 3

  def consume
    messages.each { |message| process(message.payload) }
  end

  private

  def process(payload)
    return unless payload["webhook_type"] == "TRANSACTIONS"

    bank_account = BankAccount.find_by(plaid_item_id: payload["item_id"])
    return unless bank_account

    flag_anomalies(bank_account)
  end

  def flag_anomalies(bank_account)
    bank_account.transactions
      .where(flagged_anomaly_at: nil, status: :posted)
      .where("amount_cents > 0")
      .where.not(category_id: nil)
      .find_each { |transaction| flag_if_anomalous(transaction) }
  end

  def flag_if_anomalous(transaction)
    average_cents = trailing_average_cents(transaction)
    return if average_cents.nil?

    transaction.update!(flagged_anomaly_at: Time.current) if transaction.amount_cents > average_cents * ANOMALY_MULTIPLIER
  end

  def trailing_average_cents(transaction)
    month_start = transaction.posted_at.to_date.beginning_of_month
    window = (month_start - LOOKBACK_MONTHS.months)...month_start

    history = Transaction
      .joins(:bank_account)
      .where(bank_accounts: { user_id: transaction.bank_account.user_id })
      .where(category_id: transaction.category_id, status: :posted)
      .where("transactions.amount_cents > 0")
      .where(posted_at: window)
      .where.not(id: transaction.id)

    return nil if history.count < MIN_HISTORY_COUNT

    history.average(:amount_cents).to_f
  end
end
