class DashboardData
  def initialize(user, month: Date.current.beginning_of_month)
    @user = user
    @month = month
  end

  def spent_this_month_cents
    monthly_summaries_for(@month).sum(&:total_spent_cents)
  end

  def spent_last_month_cents
    monthly_summaries_for(@month - 1.month).sum(&:total_spent_cents)
  end

  private

  def monthly_summaries_for(month)
    @user.monthly_summaries.where(month: month)
  end
end
