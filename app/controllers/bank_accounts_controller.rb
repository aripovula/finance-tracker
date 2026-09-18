class BankAccountsController < ApplicationController
  before_action :require_login

  def index
    @bank_accounts = current_user.bank_accounts.order(:institution_name)
  end

  def link_token
    render json: { link_token: PlaidService.new.create_link_token(current_user) }
  end

  def create
    PlaidService.new.exchange_public_token(
      current_user, params[:public_token],
      institution_name: params[:institution_name],
      plaid_account_id: params[:account_id],
      mask: params[:mask]
    )

    head :created
  rescue ActiveRecord::RecordInvalid => e
    render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
  end
end
