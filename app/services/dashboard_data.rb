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

  def total_budget_cents
    budgets_for(@month).sum(:monthly_limit_cents)
  end

  def budget_remaining_cents
    total_budget_cents - spent_this_month_cents
  end

  def budget_used_pct
    return nil if total_budget_cents.zero?

    (spent_this_month_cents / total_budget_cents.to_f) * 100
  end

  private

  def budgets_for(month)
    @user.budgets.where(effective_month: month)
  end

  def monthly_summaries_for(month)
    @user.monthly_summaries.where(month: month)
  end
end
