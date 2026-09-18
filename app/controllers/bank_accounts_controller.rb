class BankAccountsController < ApplicationController
  before_action :require_login

  def index
    @bank_accounts = current_user.bank_accounts.order(:institution_name)
  end

  def link_token
    render json: { link_token: PlaidService.new.create_link_token(current_user) }
  end
end
