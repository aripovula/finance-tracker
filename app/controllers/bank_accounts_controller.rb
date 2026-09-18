class BankAccountsController < ApplicationController
  before_action :require_login

  def index
    @bank_accounts = current_user.bank_accounts.order(:institution_name)
  end
end
