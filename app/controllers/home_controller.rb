class HomeController < ApplicationController
  before_action :require_login

  def index
    @dashboard = DashboardData.new(current_user)
    @budget_alerts = current_user.budget_alerts.active.includes(budget: :category)
  end
end
