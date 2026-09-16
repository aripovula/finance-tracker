class BudgetsController < ApplicationController
  before_action :require_login

  def index
    @budgets = current_user.budgets.includes(:category).order(effective_month: :desc)
  end

  def new
    @budget = current_user.budgets.new
  end

  def create
    @budget = current_user.budgets.new(budget_params)

    if @budget.save
      redirect_to budgets_path, notice: "Budget created"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def budget_params
    params.require(:budget).permit(:category_id, :monthly_limit_cents, :effective_month)
  end
end
