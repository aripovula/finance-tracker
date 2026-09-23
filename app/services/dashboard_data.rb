class DashboardData
  INVESTMENT_CATEGORY_CODE = "TRANSFER_OUT_INVESTMENT_AND_RETIREMENT_FUNDS".freeze

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

  def invested_this_month_cents
    invested_for(@month)
  end

  def invested_last_month_cents
    invested_for(@month - 1.month)
  end

  private

  def invested_for(month)
    Transaction
      .joins(:bank_account, :category)
      .where(bank_accounts: { user_id: @user.id })
      .where(categories: { plaid_category_id: INVESTMENT_CATEGORY_CODE })
      .where(status: :posted)
      .where("transactions.amount_cents > 0")
      .where(posted_at: month.all_month)
      .sum(:amount_cents)
  end

  def budgets_for(month)
    @user.budgets.where(effective_month: month)
  end

  def monthly_summaries_for(month)
    @user.monthly_summaries.where(month: month)
  end
end
