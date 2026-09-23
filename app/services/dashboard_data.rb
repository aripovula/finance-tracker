class DashboardData
  INVESTMENT_CATEGORY_CODE = "TRANSFER_OUT_INVESTMENT_AND_RETIREMENT_FUNDS".freeze
  # Plaid's own Sandbox categorizer files these as a generic account transfer (low
  # confidence) rather than the investment PFC code, so we also recognize them by name.
  INVESTMENT_MERCHANT_KEYWORDS = [ "CD DEPOSIT" ].freeze

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

  def over_budget_budgets
    summaries_by_category = monthly_summaries_for(@month).index_by(&:category_id)

    budgets_for(@month).includes(:category).select do |budget|
      spent = summaries_by_category[budget.category_id]&.total_spent_cents || 0
      spent > budget.monthly_limit_cents
    end
  end

  def spend_trend(months_count: 12)
    months = (months_count - 1).downto(0).map { |offset| @month - offset.months }
    totals = @user.monthly_summaries.where(month: months).group(:month).sum(:total_spent_cents)

    months.map { |month| { month: month, total_spent_cents: totals[month] || 0 } }
  end

  def invested_this_month_cents
    invested_for(@month)
  end

  def invested_last_month_cents
    invested_for(@month - 1.month)
  end

  def budget_comparisons
    summaries_by_category = monthly_summaries_for(@month).index_by(&:category_id)

    budgets_for(@month).includes(:category).order("categories.name").map do |budget|
      spent_cents = summaries_by_category[budget.category_id]&.total_spent_cents || 0
      delta_pct = ((spent_cents - budget.monthly_limit_cents) / budget.monthly_limit_cents.to_f) * 100

      {
        category_name: budget.category.name,
        budget_cents: budget.monthly_limit_cents,
        spent_cents: spent_cents,
        delta_pct: delta_pct,
        status: budget_status(delta_pct)
      }
    end
  end

  def category_breakdown(months_count: 5)
    months = (months_count - 1).downto(0).map { |offset| @month - offset.months }
    summaries = @user.monthly_summaries.where(month: months).includes(:category).to_a

    totals = Hash.new(0)
    summaries.each { |summary| totals[summary.category.name] += summary.total_spent_cents }
    top_names = totals.sort_by { |_name, cents| -cents }.first(5).map(&:first)

    by_month = months.index_with { Hash.new(0) }
    summaries.each do |summary|
      name = top_names.include?(summary.category.name) ? summary.category.name : "Other"
      by_month[summary.month][name] += summary.total_spent_cents
    end

    has_other = by_month.values.any? { |month_totals| month_totals.key?("Other") }
    series_names = has_other ? top_names + [ "Other" ] : top_names

    rows = months.map { |month| { month: month, values: series_names.map { |name| by_month[month][name] } } }

    { series_names: series_names, rows: rows }
  end

  def recent_investment_transactions(limit: 3)
    investment_transactions_scope.order(posted_at: :desc).limit(limit)
  end

  private

  def budget_status(delta_pct)
    return :critical if delta_pct >= 15
    return :good if delta_pct <= -15

    :warning
  end

  def invested_for(month)
    investment_transactions_scope.where(posted_at: month.all_month).sum(:amount_cents)
  end

  def investment_transactions_scope
    keyword_clause = INVESTMENT_MERCHANT_KEYWORDS.map { "transactions.merchant_name ILIKE ?" }.join(" OR ")
    keyword_binds = INVESTMENT_MERCHANT_KEYWORDS.map { |keyword| "%#{keyword}%" }

    Transaction
      .joins(:bank_account, :category)
      .where(bank_accounts: { user_id: @user.id })
      .where(status: :posted)
      .where("transactions.amount_cents > 0")
      .where([ "categories.plaid_category_id = ? OR (#{keyword_clause})", INVESTMENT_CATEGORY_CODE, *keyword_binds ])
  end

  def budgets_for(month)
    @user.budgets.where(effective_month: month)
  end

  def monthly_summaries_for(month)
    @user.monthly_summaries.where(month: month)
  end
end
