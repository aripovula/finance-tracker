class TransactionsController < ApplicationController
  before_action :require_login

  def index
    @transactions = current_user_transactions.includes(:category, :bank_account).order(posted_at: :desc)
  end

  private

  def current_user_transactions
    Transaction.joins(:bank_account).where(bank_accounts: { user_id: current_user.id })
  end
end
