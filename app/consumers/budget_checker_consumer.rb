class BudgetCheckerConsumer < ApplicationConsumer
  ALERT_THROTTLE_SECONDS = 86_400

  def consume
    messages.each { |message| process(message.payload) }
  end

  private

  def process(payload)
    return unless payload["webhook_type"] == "TRANSACTIONS"

    bank_account = BankAccount.find_by(plaid_item_id: payload["item_id"])
    return unless bank_account

    check_budgets(bank_account.user)
  end

  def check_budgets(user)
    month = Date.current.beginning_of_month

    user.budgets.where(effective_month: month).each do |budget|
      spent_cents = spent_this_month(user, budget.category, month)
      next if spent_cents <= budget.monthly_limit_cents
      next unless throttle!(user, budget.category)

      BudgetAlert.create!(budget: budget, spent_cents: spent_cents)
    end
  end

  def spent_this_month(user, category, month)
    Transaction
      .joins(:bank_account)
      .where(bank_accounts: { user_id: user.id })
      .where(category: category, status: :posted)
      .where("transactions.amount_cents > 0")
      .where(posted_at: month.all_month)
      .sum(:amount_cents)
  end

  def throttle!(user, category)
    AppRedis.client.set("alert:#{user.id}:#{category.id}:#{Date.current}", "1", nx: true, ex: ALERT_THROTTLE_SECONDS)
  end
end
