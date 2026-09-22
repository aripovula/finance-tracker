class BudgetAlertsController < ApplicationController
  before_action :require_login

  def update
    alert = current_user.budget_alerts.find(params[:id])
    alert.update!(dismissed_at: Time.current)

    redirect_to root_path
  end
end
