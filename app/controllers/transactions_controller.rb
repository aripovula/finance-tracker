require "csv"

class TransactionsController < ApplicationController
  before_action :require_login

  def index
    @transactions = current_user_transactions.includes(:category, :bank_account).order(posted_at: :desc)

    respond_to do |format|
      format.html
      format.csv { send_data transactions_csv(@transactions), filename: "transactions-#{Date.current.iso8601}.csv" }
    end
  end

  def show
    @transaction = current_user_transactions.find(params[:id])
  end

  private

  def current_user_transactions
    Transaction.joins(:bank_account).where(bank_accounts: { user_id: current_user.id })
  end

  # Exports every one of the user's transactions, not just whatever the
  # client-side search/date filter currently shows - the server has no idea
  # what that filter's state is, since it never makes a request.
  def transactions_csv(transactions)
    CSV.generate(headers: true) do |csv|
      csv << [ "Merchant", "Category", "Amount", "Status", "Posted" ]

      transactions.each do |transaction|
        csv << [
          csv_safe(transaction.merchant_name.presence || "Unknown"),
          csv_safe(transaction.category&.name || "Uncategorized"),
          helpers.transaction_amount_label(transaction),
          transaction.status,
          transaction.posted_at&.to_date
        ]
      end
    end
  end

  # Merchant/category names ultimately come from bank-reported data, not
  # something we control, so a leading =/+/-/@ gets neutralized before it
  # reaches a cell - Excel/Sheets treat those as the start of a formula
  # (the classic "CSV injection" issue).
  def csv_safe(value)
    value.to_s.sub(/\A([=+\-@])/, "'\\1")
  end
end
