# Seeds LOADTEST_USER_COUNT (default 20) distinct users, each with their own
# bank account and a small, unique set of transactions, and mints each
# user's JWT directly via JsonWebToken.encode - skipping the HTTP login
# round trip (and its bcrypt cost, see loadtest/login.js) entirely, since
# this test is about /api/v1/transactions, not login.
#
# Writes one record per user to tmp/loadtest_transaction_users.json for
# loadtest/transactions.js to read: {user_id, email, bank_account_id,
# transaction_count, token}. Regenerated fresh on every run - not meant to
# be committed (tmp/ is gitignored).
#
# Run with: bin/rails runner loadtest/seed_transaction_users.rb
# Local/dev only - creates real rows in whatever database RAILS_ENV points at.

require "json"

USER_COUNT = Integer(ENV.fetch("LOADTEST_USER_COUNT", 20))
TRANSACTIONS_PER_USER = 5
OUTPUT_PATH = Rails.root.join("tmp", "loadtest_transaction_users.json")

category = Category.where.not(parent_category_id: nil).order(:id).first
raise "No categories found - run `bin/rails db:seed` first" unless category

records = Array.new(USER_COUNT) do |i|
  user = User.find_or_create_by!(email: "loadtest-txn-user-#{i}@example.com") { |u| u.password = "password123" }

  bank_account = user.bank_accounts.find_or_create_by!(plaid_account_id: "loadtest-txn-account-#{i}") do |ba|
    ba.plaid_item_id = "loadtest-txn-item-#{i}"
    ba.plaid_access_token = "loadtest-txn-access-#{i}"
    ba.institution_name = "Load Test Bank"
    ba.mask = format("%04d", i)
  end

  TRANSACTIONS_PER_USER.times do |j|
    Transaction.find_or_create_by!(plaid_transaction_id: "loadtest-txn-#{i}-#{j}") do |txn|
      txn.bank_account = bank_account
      txn.category = category
      txn.amount_cents = rand(500..15_000)
      txn.merchant_name = "Load Test Merchant #{j}"
      txn.posted_at = j.days.ago
      txn.status = :posted
      txn.raw_payload = { source: "loadtest" }
    end
  end

  {
    user_id: user.id,
    email: user.email,
    bank_account_id: bank_account.id,
    transaction_count: TRANSACTIONS_PER_USER,
    token: JsonWebToken.encode({ user_id: user.id }, expires_in: 1.hour)
  }
end

File.write(OUTPUT_PATH, JSON.pretty_generate(records))

puts "Wrote #{records.size} users (#{TRANSACTIONS_PER_USER} transactions each) to #{OUTPUT_PATH}"
