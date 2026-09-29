# Seeds a dedicated user with categorized, posted transactions and rebuilds
# monthly_summaries, so the k6 script in this directory has real read-model
# rows to hit instead of an empty dashboard.
#
# Run with: bin/rails runner loadtest/seed.rb
#
# Local/dev only. NightlySummaryRebuildJob rebuilds monthly_summaries for
# EVERY user (it's a full delete_all + recompute, matching the real nightly
# job) - don't run this against a database you care about.

LOADTEST_EMAIL = "loadtest@example.com".freeze

user = User.find_or_create_by!(email: LOADTEST_EMAIL) { |u| u.password = "password123" }

bank_account = user.bank_accounts.find_or_create_by!(plaid_account_id: "loadtest-account") do |ba|
  ba.plaid_item_id = "loadtest-item"
  ba.plaid_access_token = "loadtest-access-token"
  ba.institution_name = "Load Test Bank"
  ba.mask = "0000"
end

categories = Category.where.not(parent_category_id: nil).order(:id).limit(5).to_a
raise "No categories found - run `bin/rails db:seed` first" if categories.empty?

(0..2).each do |months_ago|
  month = months_ago.months.ago.beginning_of_month

  categories.each do |category|
    5.times do |i|
      Transaction.find_or_create_by!(plaid_transaction_id: "loadtest-#{category.id}-#{months_ago}-#{i}") do |txn|
        txn.bank_account = bank_account
        txn.category = category
        txn.amount_cents = rand(500..15_000)
        txn.merchant_name = "Load Test Merchant #{i}"
        txn.posted_at = month + i.days
        txn.status = :posted
        txn.raw_payload = { source: "loadtest" }
      end
    end
  end
end

NightlySummaryRebuildJob.perform_now

puts "Seeded #{LOADTEST_EMAIL} with #{user.reload.bank_accounts.sum { |ba| ba.transactions.count }} transactions " \
     "across #{categories.size} categories, and rebuilt monthly_summaries."
