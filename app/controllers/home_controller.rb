class HomeController < ApplicationController
  before_action :require_login

  def index
    @budget_alerts = current_user.budget_alerts.active.includes(budget: :category)
    @monthly_summaries = current_user.monthly_summaries
      .where(month: Date.current.beginning_of_month)
      .includes(:category)
      .order(total_spent_cents: :desc)
  end
end
