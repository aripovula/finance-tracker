class BudgetsController < ApplicationController
  before_action :require_login

  def index
    @budgets = current_user.budgets.includes(:category).order(effective_month: :desc)
  end
end
