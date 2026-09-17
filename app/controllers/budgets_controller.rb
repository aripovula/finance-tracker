class BudgetsController < ApplicationController
  before_action :require_login
  before_action :set_budget, only: [ :edit, :update, :destroy ]

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

  def edit
  end

  def update
    if @budget.update(budget_params)
      redirect_to budgets_path, notice: "Budget updated"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @budget.destroy!

    redirect_to budgets_path, notice: "Budget deleted"
  end

  private

  def set_budget
    @budget = current_user.budgets.find(params[:id])
  end

  def budget_params
    permitted = params.require(:budget).permit(:category_id, :monthly_limit, :effective_month)

    {
      category_id: permitted[:category_id],
      monthly_limit_cents: dollars_to_cents(permitted[:monthly_limit]),
      effective_month: month_param_to_date(permitted[:effective_month])
    }
  end

  def dollars_to_cents(dollars)
    return nil if dollars.blank?

    (BigDecimal(dollars) * 100).round
  end

  def month_param_to_date(month)
    return nil if month.blank?

    Date.parse("#{month}-01")
  end
end
