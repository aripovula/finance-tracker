class BudgetsController < ApplicationController
  before_action :require_login
  before_action :set_budget, only: [ :edit, :update, :destroy ]

  def index
    @budgets = current_user.budgets.includes(:category).order(effective_month: :desc)
    @suggested_budgets = suggested_budgets_for(Date.current.beginning_of_month)
  end

  def new
    @budget = current_user.budgets.new(
      category_id: params[:category_id],
      monthly_limit_cents: dollars_to_cents(params[:monthly_limit]),
      effective_month: Date.current.beginning_of_month
    )
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

  # Categories with spend in the trailing 3 months but no budget set for
  # `month`, paired with their trailing-average spend as a suggested amount.
  def suggested_budgets_for(month)
    dashboard = DashboardData.new(current_user, month: month)
    budgeted_category_ids = current_user.budgets.where(effective_month: month).pluck(:category_id)
    trailing_window = (1..3).map { |offset| month - offset.months }
    candidate_category_ids = current_user.monthly_summaries.where(month: trailing_window).distinct.pluck(:category_id) - budgeted_category_ids

    Category.where(id: candidate_category_ids).order(:name).filter_map do |category|
      average_cents = dashboard.trailing_average_cents(category)
      { category: category, average_cents: average_cents } if average_cents.positive?
    end
  end
end
