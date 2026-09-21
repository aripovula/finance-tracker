class NightlySummaryRebuildJob < ApplicationJob
  queue_as :default

  def perform
    totals = Transaction
      .joins(:bank_account)
      .where(status: :posted)
      .where("transactions.amount_cents > 0")
      .where.not(category_id: nil)
      .group("bank_accounts.user_id", "transactions.category_id", Arel.sql("date_trunc('month', posted_at)"))
      .sum(:amount_cents)

    MonthlySummary.transaction do
      MonthlySummary.delete_all

      totals.each do |(user_id, category_id, month), total_cents|
        MonthlySummary.create!(user_id: user_id, category_id: category_id, month: month.to_date, total_spent_cents: total_cents)
      end
    end
  end
end
