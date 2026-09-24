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
    budget_comparisons.sum { |comparison| comparison[:budget_cents] }
  end

  def budget_remaining_cents
    total_budget_cents - budget_comparisons.sum { |comparison| comparison[:spent_cents] }
  end

  def budget_used_pct
    return nil if total_budget_cents.zero?

    (budget_comparisons.sum { |comparison| comparison[:spent_cents] } / total_budget_cents.to_f) * 100
  end

  # Every category over its comparison baseline this month - a user budget where
  # one is set, otherwise the trailing-average fallback from budget_comparisons.
  def over_budget_comparisons
    budget_comparisons.select { |comparison| comparison[:spent_cents] > comparison[:budget_cents] }
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

  # For each category with either a user-set budget or spend this month: compare
  # against the user's budget if they set one, otherwise fall back to the
  # trailing 3-month average (skipped if that average is zero - nothing to
  # compare against yet). This keeps every spending category represented, not
  # just the handful the user has explicitly budgeted. Sorted by the size of
  # the deviation (largest first), so callers can take the top N.
  def budget_comparisons
    @budget_comparisons ||= begin
      summaries_by_category = monthly_summaries_for(@month).index_by(&:category_id)
      user_budgets_by_category = budgets_for(@month).index_by(&:category_id)
      categories_by_id = Category.where(id: (summaries_by_category.keys + user_budgets_by_category.keys).uniq).index_by(&:id)

      comparisons = categories_by_id.filter_map do |category_id, category|
        spent_cents = summaries_by_category[category_id]&.total_spent_cents || 0
        user_budget = user_budgets_by_category[category_id]

        if user_budget
          budget_cents = user_budget.monthly_limit_cents
          category_name = category.name
        else
          budget_cents = trailing_average_cents(category)
          next if budget_cents.zero?

          category_name = "#{category.name} (avg)"
        end

        delta_pct = ((spent_cents - budget_cents) / budget_cents.to_f) * 100

        { category_name: category_name, budget_cents: budget_cents, spent_cents: spent_cents, delta_pct: delta_pct, status: budget_status(delta_pct) }
      end

      comparisons.sort_by { |comparison| -comparison[:delta_pct].abs }
    end
  end

  # Average monthly spend for a category over the trailing N months (missing
  # months count as zero, matching spend_trend/category_breakdown).
  def trailing_average_cents(category, months: 3)
    window = (1..months).map { |offset| @month - offset.months }
    total = @user.monthly_summaries.where(category: category, month: window).sum(:total_spent_cents)

    (total / months.to_f).round
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
