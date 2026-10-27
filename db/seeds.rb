# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Plaid's Personal Finance Category taxonomy (primary -> detailed), so the categorizer
# consumer (app/consumers/categorizer_consumer.rb) has real categories to match
# transactions.raw_payload["personal_finance_category"]["detailed"] against.
PLAID_PERSONAL_FINANCE_CATEGORIES = {
  "INCOME" => {
    name: "Income",
    detailed: {
      "INCOME_DIVIDENDS" => "Dividends",
      "INCOME_INTEREST_EARNED" => "Interest Earned",
      "INCOME_RETIREMENT_PENSION" => "Retirement Pension",
      "INCOME_TAX_REFUND" => "Tax Refund",
      "INCOME_UNEMPLOYMENT" => "Unemployment",
      "INCOME_WAGES" => "Wages",
      "INCOME_OTHER_INCOME" => "Other Income"
    }
  },
  "TRANSFER_IN" => {
    name: "Transfer In",
    detailed: {
      "TRANSFER_IN_CASH_ADVANCES_AND_LOANS" => "Cash Advances And Loans",
      "TRANSFER_IN_DEPOSIT" => "Deposit",
      "TRANSFER_IN_INVESTMENT_AND_RETIREMENT_FUNDS" => "Investment And Retirement Funds",
      "TRANSFER_IN_SAVINGS" => "Savings",
      "TRANSFER_IN_ACCOUNT_TRANSFER" => "Account Transfer",
      "TRANSFER_IN_OTHER_TRANSFER_IN" => "Other Transfer In"
    }
  },
  "TRANSFER_OUT" => {
    name: "Transfer Out",
    detailed: {
      "TRANSFER_OUT_INVESTMENT_AND_RETIREMENT_FUNDS" => "Investment And Retirement Funds",
      "TRANSFER_OUT_SAVINGS" => "Savings",
      "TRANSFER_OUT_WITHDRAWAL" => "Withdrawal",
      "TRANSFER_OUT_ACCOUNT_TRANSFER" => "Account Transfer",
      "TRANSFER_OUT_OTHER_TRANSFER_OUT" => "Other Transfer Out"
    }
  },
  "LOAN_PAYMENTS" => {
    name: "Loan Payments",
    detailed: {
      "LOAN_PAYMENTS_CAR_PAYMENT" => "Car Payment",
      "LOAN_PAYMENTS_CREDIT_CARD_PAYMENT" => "Credit Card Payment",
      "LOAN_PAYMENTS_PERSONAL_LOAN_PAYMENT" => "Personal Loan Payment",
      "LOAN_PAYMENTS_MORTGAGE_PAYMENT" => "Mortgage Payment",
      "LOAN_PAYMENTS_STUDENT_LOAN_PAYMENT" => "Student Loan Payment",
      "LOAN_PAYMENTS_OTHER_PAYMENT" => "Other Payment"
    }
  },
  "BANK_FEES" => {
    name: "Bank Fees",
    detailed: {
      "BANK_FEES_ATM_FEES" => "ATM Fees",
      "BANK_FEES_FOREIGN_TRANSACTION_FEES" => "Foreign Transaction Fees",
      "BANK_FEES_INSUFFICIENT_FUNDS" => "Insufficient Funds",
      "BANK_FEES_INTEREST_CHARGE" => "Interest Charge",
      "BANK_FEES_OVERDRAFT_FEES" => "Overdraft Fees",
      "BANK_FEES_OTHER_BANK_FEES" => "Other Bank Fees"
    }
  },
  "ENTERTAINMENT" => {
    name: "Entertainment",
    detailed: {
      "ENTERTAINMENT_CASINOS_AND_GAMBLING" => "Casinos And Gambling",
      "ENTERTAINMENT_MUSIC_AND_AUDIO" => "Music And Audio",
      "ENTERTAINMENT_SPORTING_EVENTS_AMUSEMENT_PARKS_AND_MUSEUMS" => "Sporting Events, Amusement Parks And Museums",
      "ENTERTAINMENT_TV_AND_MOVIES" => "TV And Movies",
      "ENTERTAINMENT_VIDEO_GAMES" => "Video Games",
      "ENTERTAINMENT_OTHER_ENTERTAINMENT" => "Other Entertainment"
    }
  },
  "FOOD_AND_DRINK" => {
    name: "Food And Drink",
    detailed: {
      "FOOD_AND_DRINK_BEER_WINE_AND_LIQUOR" => "Beer, Wine And Liquor",
      "FOOD_AND_DRINK_COFFEE" => "Coffee",
      "FOOD_AND_DRINK_FAST_FOOD" => "Fast Food",
      "FOOD_AND_DRINK_GROCERIES" => "Groceries",
      "FOOD_AND_DRINK_RESTAURANT" => "Restaurants",
      "FOOD_AND_DRINK_VENDING_MACHINES" => "Vending Machines",
      "FOOD_AND_DRINK_OTHER_FOOD_AND_DRINK" => "Other Food And Drink"
    }
  },
  "GENERAL_MERCHANDISE" => {
    name: "General Merchandise",
    detailed: {
      "GENERAL_MERCHANDISE_BOOKSTORES_AND_NEWSSTANDS" => "Bookstores And Newsstands",
      "GENERAL_MERCHANDISE_CLOTHING_AND_ACCESSORIES" => "Clothing And Accessories",
      "GENERAL_MERCHANDISE_CONVENIENCE_STORES" => "Convenience Stores",
      "GENERAL_MERCHANDISE_DEPARTMENT_STORES" => "Department Stores",
      "GENERAL_MERCHANDISE_DISCOUNT_STORES" => "Discount Stores",
      "GENERAL_MERCHANDISE_ELECTRONICS" => "Electronics",
      "GENERAL_MERCHANDISE_GIFTS_AND_NOVELTIES" => "Gifts And Novelties",
      "GENERAL_MERCHANDISE_OFFICE_SUPPLIES" => "Office Supplies",
      "GENERAL_MERCHANDISE_ONLINE_MARKETPLACES" => "Online Marketplaces",
      "GENERAL_MERCHANDISE_PET_SUPPLIES" => "Pet Supplies",
      "GENERAL_MERCHANDISE_SPORTING_GOODS" => "Sporting Goods",
      "GENERAL_MERCHANDISE_SUPERSTORES" => "Superstores",
      "GENERAL_MERCHANDISE_TOBACCO_AND_VAPE" => "Tobacco And Vape",
      "GENERAL_MERCHANDISE_OTHER_GENERAL_MERCHANDISE" => "Other General Merchandise"
    }
  },
  "HOME_IMPROVEMENT" => {
    name: "Home Improvement",
    detailed: {
      "HOME_IMPROVEMENT_FURNITURE" => "Furniture",
      "HOME_IMPROVEMENT_HARDWARE" => "Hardware",
      "HOME_IMPROVEMENT_REPAIR_AND_MAINTENANCE" => "Repair And Maintenance",
      "HOME_IMPROVEMENT_SECURITY" => "Security",
      "HOME_IMPROVEMENT_OTHER_HOME_IMPROVEMENT" => "Other Home Improvement"
    }
  },
  "MEDICAL" => {
    name: "Medical",
    detailed: {
      "MEDICAL_DENTAL_CARE" => "Dental Care",
      "MEDICAL_EYE_CARE" => "Eye Care",
      "MEDICAL_NURSING_CARE" => "Nursing Care",
      "MEDICAL_PHARMACIES_AND_SUPPLEMENTS" => "Pharmacies And Supplements",
      "MEDICAL_PRIMARY_CARE" => "Primary Care",
      "MEDICAL_VETERINARY_SERVICES" => "Veterinary Services",
      "MEDICAL_OTHER_MEDICAL" => "Other Medical"
    }
  },
  "PERSONAL_CARE" => {
    name: "Personal Care",
    detailed: {
      "PERSONAL_CARE_GYMS_AND_FITNESS_CENTERS" => "Gyms And Fitness Centers",
      "PERSONAL_CARE_HAIR_AND_BEAUTY" => "Hair And Beauty",
      "PERSONAL_CARE_LAUNDRY_AND_DRY_CLEANING" => "Laundry And Dry Cleaning",
      "PERSONAL_CARE_OTHER_PERSONAL_CARE" => "Other Personal Care"
    }
  },
  "GENERAL_SERVICES" => {
    name: "General Services",
    detailed: {
      "GENERAL_SERVICES_ACCOUNTING_AND_FINANCIAL_PLANNING" => "Accounting And Financial Planning",
      "GENERAL_SERVICES_AUTOMOTIVE" => "Automotive",
      "GENERAL_SERVICES_CHILDCARE" => "Childcare",
      "GENERAL_SERVICES_CONSULTING_AND_LEGAL" => "Consulting And Legal",
      "GENERAL_SERVICES_EDUCATION" => "Education",
      "GENERAL_SERVICES_INSURANCE" => "Insurance",
      "GENERAL_SERVICES_POSTAGE_AND_SHIPPING" => "Postage And Shipping",
      "GENERAL_SERVICES_STORAGE" => "Storage",
      "GENERAL_SERVICES_OTHER_GENERAL_SERVICES" => "Other General Services"
    }
  },
  "GOVERNMENT_AND_NON_PROFIT" => {
    name: "Government And Non-Profit",
    detailed: {
      "GOVERNMENT_AND_NON_PROFIT_DONATIONS" => "Donations",
      "GOVERNMENT_AND_NON_PROFIT_GOVERNMENT_DEPARTMENTS_AND_AGENCIES" => "Government Departments And Agencies",
      "GOVERNMENT_AND_NON_PROFIT_TAX_PAYMENT" => "Tax Payment",
      "GOVERNMENT_AND_NON_PROFIT_OTHER_GOVERNMENT_AND_NON_PROFIT" => "Other Government And Non-Profit"
    }
  },
  "TRANSPORTATION" => {
    name: "Transportation",
    detailed: {
      "TRANSPORTATION_BIKES_AND_SCOOTERS" => "Bikes And Scooters",
      "TRANSPORTATION_GAS" => "Gas",
      "TRANSPORTATION_PARKING" => "Parking",
      "TRANSPORTATION_PUBLIC_TRANSIT" => "Public Transit",
      "TRANSPORTATION_TAXIS_AND_RIDE_SHARES" => "Taxis And Ride Shares",
      "TRANSPORTATION_TOLLS" => "Tolls",
      "TRANSPORTATION_OTHER_TRANSPORTATION" => "Other Transportation"
    }
  },
  "TRAVEL" => {
    name: "Travel",
    detailed: {
      "TRAVEL_FLIGHTS" => "Flights",
      "TRAVEL_LODGING" => "Lodging",
      "TRAVEL_RENTAL_CARS" => "Rental Cars",
      "TRAVEL_OTHER_TRAVEL" => "Other Travel"
    }
  },
  "RENT_AND_UTILITIES" => {
    name: "Rent And Utilities",
    detailed: {
      "RENT_AND_UTILITIES_GAS_AND_ELECTRICITY" => "Gas And Electricity",
      "RENT_AND_UTILITIES_INTERNET_AND_CABLE" => "Internet And Cable",
      "RENT_AND_UTILITIES_RENT" => "Rent",
      "RENT_AND_UTILITIES_SEWAGE_AND_WASTE_MANAGEMENT" => "Sewage And Waste Management",
      "RENT_AND_UTILITIES_TELEPHONE" => "Telephone",
      "RENT_AND_UTILITIES_WATER" => "Water",
      "RENT_AND_UTILITIES_OTHER_UTILITIES" => "Other Utilities"
    }
  }
}.freeze

PLAID_PERSONAL_FINANCE_CATEGORIES.each do |primary_code, primary|
  primary_category = Category.find_or_create_by!(plaid_category_id: primary_code) do |category|
    category.name = primary[:name]
  end

  primary[:detailed].each do |detailed_code, detailed_name|
    Category.find_or_create_by!(plaid_category_id: detailed_code) do |category|
      category.name = detailed_name
      category.parent_category = primary_category
    end
  end
end

# --- Demo users ----------------------------------------------------------
# Three preset accounts a visitor can log into with one click from the
# login page (DemoUserPresets, app/views/sessions/new.html.erb) instead of
# registering or guessing credentials - this is a public demo with no real
# user data to protect. Dates are expressed as offsets from the start of
# the current month, not from "now", so re-seeding stays correct no matter
# which day of the month it's run on.
DEMO_TRANSACTIONS_THIS_MONTH = [
  { category: "Groceries", merchant: "Whole Foods Market", amount_cents: 8734, day_of_month: 3 },
  { category: "Groceries", merchant: "Trader Joe's", amount_cents: 5210, day_of_month: 16 },
  { category: "Restaurants", merchant: "Chipotle", amount_cents: 2599, day_of_month: 2 },
  { category: "Restaurants", merchant: "Olive Garden", amount_cents: 5890, day_of_month: 11 },
  { category: "Restaurants", merchant: "Shake Shack", amount_cents: 3120, day_of_month: 22 },
  { category: "Coffee", merchant: "Starbucks", amount_cents: 575, day_of_month: 4 },
  { category: "Gas", merchant: "Shell", amount_cents: 4820, day_of_month: 7 },
  { category: "Rent", merchant: "Parkview Apartments", amount_cents: 152000, day_of_month: 1 },
  { category: "Internet And Cable", merchant: "Comcast Xfinity", amount_cents: 7999, day_of_month: 5 },
  { category: "TV And Movies", merchant: "Netflix", amount_cents: 1549, day_of_month: 9 }
].freeze

DEMO_TRANSACTIONS_LAST_MONTH = [
  { category: "Groceries", merchant: "Safeway", amount_cents: 6120, day_of_month: 12 },
  { category: "Restaurants", merchant: "Shake Shack", amount_cents: 2780, day_of_month: 20 },
  { category: "Clothing And Accessories", merchant: "Gap", amount_cents: 6450, day_of_month: 14 },
  { category: "Gyms And Fitness Centers", merchant: "Planet Fitness", amount_cents: 3999, day_of_month: 3 }
].freeze

# A second, much larger account for Alex (alongside the small Bank of America
# one above) - demos multi-bank support and gives panels that stay empty
# with only the default small seed set (like "Investment transfers",
# DashboardData#recent_investment_transactions) something real to show.
# TRANSFER_OUT_INVESTMENT_AND_RETIREMENT_FUNDS is looked up by Plaid category
# *code*, not name: its detailed name ("Investment And Retirement Funds") is
# shared with TRANSFER_IN's own code of the same name, so a name lookup
# would be ambiguous - see seed_demo_transaction! below.
WELLS_FARGO_TRANSACTIONS_THIS_MONTH = [
  { category: "Wages", merchant: "Globex Corp Payroll", amount_cents: 285000, day_of_month: 1 },
  { category: "Wages", merchant: "Globex Corp Payroll", amount_cents: 285000, day_of_month: 15 },
  { category_code: "TRANSFER_OUT_INVESTMENT_AND_RETIREMENT_FUNDS", merchant: "Fidelity 401(k) Contribution", amount_cents: 45000, day_of_month: 15 },
  { category_code: "TRANSFER_OUT_INVESTMENT_AND_RETIREMENT_FUNDS", merchant: "Charles Schwab Brokerage Transfer", amount_cents: 120000, day_of_month: 24 },
  { category: "Rent", merchant: "Parkview Apartments", amount_cents: 152000, day_of_month: 1 },
  { category: "Gas And Electricity", merchant: "PG&E", amount_cents: 11420, day_of_month: 6 },
  { category: "Internet And Cable", merchant: "Comcast Xfinity", amount_cents: 7999, day_of_month: 5 },
  { category: "Water", merchant: "City Water Utility", amount_cents: 3850, day_of_month: 8 },
  { category: "Telephone", merchant: "Verizon Wireless", amount_cents: 8500, day_of_month: 10 },
  { category: "Groceries", merchant: "Whole Foods Market", amount_cents: 9340, day_of_month: 2 },
  { category: "Groceries", merchant: "Trader Joe's", amount_cents: 5480, day_of_month: 9 },
  { category: "Superstores", merchant: "Costco", amount_cents: 18760, day_of_month: 13 },
  { category: "Groceries", merchant: "Whole Foods Market", amount_cents: 7220, day_of_month: 23 },
  { category: "Restaurants", merchant: "Chipotle", amount_cents: 2450, day_of_month: 3 },
  { category: "Restaurants", merchant: "Olive Garden", amount_cents: 6120, day_of_month: 11 },
  { category: "Fast Food", merchant: "Chick-fil-A", amount_cents: 1875, day_of_month: 14 },
  { category: "Restaurants", merchant: "Nobu", amount_cents: 18900, day_of_month: 19 },
  { category: "Coffee", merchant: "Starbucks", amount_cents: 650, day_of_month: 4 },
  { category: "Coffee", merchant: "Starbucks", amount_cents: 710, day_of_month: 18 },
  { category: "Beer, Wine And Liquor", merchant: "BevMo", amount_cents: 5430, day_of_month: 21 },
  { category: "Gas", merchant: "Shell", amount_cents: 5120, day_of_month: 7 },
  { category: "Gas", merchant: "Chevron", amount_cents: 4890, day_of_month: 22 },
  { category: "Taxis And Ride Shares", merchant: "Uber", amount_cents: 2340, day_of_month: 12 },
  { category: "Parking", merchant: "SpotHero", amount_cents: 1800, day_of_month: 17 },
  { category: "TV And Movies", merchant: "Netflix", amount_cents: 1549, day_of_month: 9 },
  { category: "Music And Audio", merchant: "Spotify", amount_cents: 1099, day_of_month: 9 },
  { category: "Online Marketplaces", merchant: "Amazon", amount_cents: 6730, day_of_month: 6 },
  { category: "Online Marketplaces", merchant: "Amazon", amount_cents: 2980, day_of_month: 20 },
  { category: "Discount Stores", merchant: "Target", amount_cents: 8420, day_of_month: 16 },
  { category: "Electronics", merchant: "Best Buy", amount_cents: 24900, day_of_month: 25 },
  { category: "Video Games", merchant: "Steam", amount_cents: 5999, day_of_month: 27 },
  { category: "Gyms And Fitness Centers", merchant: "Equinox", amount_cents: 18900, day_of_month: 1 },
  { category: "Hair And Beauty", merchant: "Great Clips", amount_cents: 3200, day_of_month: 15 },
  { category: "Pharmacies And Supplements", merchant: "CVS Pharmacy", amount_cents: 4250, day_of_month: 11 },
  { category: "Dental Care", merchant: "Bright Smile Dental", amount_cents: 22000, day_of_month: 19 },
  { category: "Flights", merchant: "United Airlines", amount_cents: 48900, day_of_month: 28 },
  { category: "Lodging", merchant: "Marriott", amount_cents: 61200, day_of_month: 28 },
  { category: "ATM Fees", merchant: "Non-Network ATM Fee", amount_cents: 350, day_of_month: 10 },
  { category: "Credit Card Payment", merchant: "Wells Fargo Credit Card Payment", amount_cents: 95000, day_of_month: 20 },
  { category: "Car Payment", merchant: "Toyota Financial Services", amount_cents: 42000, day_of_month: 5 },
  { category: "Pet Supplies", merchant: "Chewy", amount_cents: 6780, day_of_month: 13 },
  { category: "Repair And Maintenance", merchant: "Handy", amount_cents: 15000, day_of_month: 23 }
].freeze

WELLS_FARGO_TRANSACTIONS_LAST_MONTH = [
  { category: "Wages", merchant: "Globex Corp Payroll", amount_cents: 285000, day_of_month: 1 },
  { category: "Wages", merchant: "Globex Corp Payroll", amount_cents: 285000, day_of_month: 15 },
  { category_code: "TRANSFER_OUT_INVESTMENT_AND_RETIREMENT_FUNDS", merchant: "Fidelity 401(k) Contribution", amount_cents: 45000, day_of_month: 15 },
  { category_code: "TRANSFER_OUT_INVESTMENT_AND_RETIREMENT_FUNDS", merchant: "Vanguard Brokerage Transfer", amount_cents: 80000, day_of_month: 29 },
  { category: "Rent", merchant: "Parkview Apartments", amount_cents: 152000, day_of_month: 1 },
  { category: "Gas And Electricity", merchant: "PG&E", amount_cents: 9870, day_of_month: 6 },
  { category: "Internet And Cable", merchant: "Comcast Xfinity", amount_cents: 7999, day_of_month: 5 },
  { category: "Telephone", merchant: "Verizon Wireless", amount_cents: 8500, day_of_month: 10 },
  { category: "Groceries", merchant: "Whole Foods Market", amount_cents: 8870, day_of_month: 4 },
  { category: "Groceries", merchant: "Safeway", amount_cents: 6340, day_of_month: 17 },
  { category: "Superstores", merchant: "Costco", amount_cents: 16420, day_of_month: 12 },
  { category: "Groceries", merchant: "Trader Joe's", amount_cents: 5120, day_of_month: 24 },
  { category: "Restaurants", merchant: "Shake Shack", amount_cents: 3010, day_of_month: 8 },
  { category: "Restaurants", merchant: "Cheesecake Factory", amount_cents: 7450, day_of_month: 16 },
  { category: "Fast Food", merchant: "Chipotle", amount_cents: 2190, day_of_month: 21 },
  { category: "Coffee", merchant: "Starbucks", amount_cents: 690, day_of_month: 9 },
  { category: "Coffee", merchant: "Blue Bottle Coffee", amount_cents: 820, day_of_month: 23 },
  { category: "Gas", merchant: "Shell", amount_cents: 4980, day_of_month: 7 },
  { category: "Taxis And Ride Shares", merchant: "Lyft", amount_cents: 1980, day_of_month: 14 },
  { category: "Public Transit", merchant: "Clipper Card", amount_cents: 12000, day_of_month: 2 },
  { category: "TV And Movies", merchant: "Netflix", amount_cents: 1549, day_of_month: 9 },
  { category: "Online Marketplaces", merchant: "Amazon", amount_cents: 5340, day_of_month: 11 },
  { category: "Clothing And Accessories", merchant: "Nordstrom", amount_cents: 14200, day_of_month: 19 },
  { category: "Furniture", merchant: "IKEA", amount_cents: 32900, day_of_month: 26 },
  { category: "Gyms And Fitness Centers", merchant: "Equinox", amount_cents: 18900, day_of_month: 1 },
  { category: "Veterinary Services", merchant: "Banfield Pet Hospital", amount_cents: 9800, day_of_month: 18 },
  { category: "Credit Card Payment", merchant: "Wells Fargo Credit Card Payment", amount_cents: 87000, day_of_month: 20 },
  { category: "Interest Charge", merchant: "Wells Fargo Interest Charge", amount_cents: 1240, day_of_month: 20 }
].freeze

# Restaurants is deliberately over its limit (seeded spend is $116.09 of a
# $100 budget) so the budget-alert banner has something to show out of the
# box; Rent is close to its limit without going over, for visual contrast.
DEMO_BUDGETS_THIS_MONTH = [
  { category: "Groceries", monthly_limit_cents: 35_000 },
  { category: "Restaurants", monthly_limit_cents: 10_000 },
  { category: "Rent", monthly_limit_cents: 160_000 }
].freeze

def seed_demo_transaction!(bank_account:, key:, posted_at:, template:)
  Transaction.find_or_create_by!(plaid_transaction_id: "txn-demo-#{key}") do |txn|
    txn.bank_account = bank_account
    # Most templates pick a category by its (unique) display name, but
    # "Investment And Retirement Funds" is Plaid's literal detailed name
    # for *both* TRANSFER_IN and TRANSFER_OUT - a name lookup there would be
    # ambiguous, so those templates give the exact plaid_category_id instead.
    txn.category = template[:category_code] ? Category.find_by!(plaid_category_id: template[:category_code]) : Category.find_by!(name: template[:category])
    txn.merchant_name = template[:merchant]
    txn.amount_cents = template[:amount_cents]
    txn.posted_at = posted_at
    txn.status = "posted"
    txn.raw_payload = { "source" => "demo-seed" }
  end
end

def seed_demo_bank_account!(user:, account_slug:, institution_name:, this_month_templates:, last_month_templates:)
  this_month = Date.current.beginning_of_month
  last_month = this_month - 1.month

  bank_account = BankAccount.find_or_create_by!(plaid_account_id: "account-demo-#{account_slug}") do |ba|
    ba.user = user
    ba.plaid_item_id = "item-demo-#{account_slug}"
    ba.plaid_access_token = "access-demo-#{account_slug}"
    ba.institution_name = institution_name
    ba.mask = rand(1000..9999).to_s
  end

  this_month_templates.each_with_index do |template, index|
    seed_demo_transaction!(
      bank_account: bank_account, key: "#{account_slug}-#{index}",
      posted_at: this_month.change(day: template[:day_of_month]), template: template
    )
  end

  last_month_templates.each_with_index do |template, index|
    seed_demo_transaction!(
      bank_account: bank_account, key: "#{account_slug}-last-month-#{index}",
      posted_at: last_month.change(day: template[:day_of_month]), template: template
    )
  end

  bank_account
end

def seed_demo_user!(name:, password:, institution_name:)
  slug = name.downcase
  this_month = Date.current.beginning_of_month

  user = User.find_or_create_by!(email: name) { |u| u.password = password }

  seed_demo_bank_account!(
    user: user, account_slug: slug, institution_name: institution_name,
    this_month_templates: DEMO_TRANSACTIONS_THIS_MONTH, last_month_templates: DEMO_TRANSACTIONS_LAST_MONTH
  )

  budgets = DEMO_BUDGETS_THIS_MONTH.map do |template|
    Budget.find_or_create_by!(
      user: user, category: Category.find_by!(name: template[:category]), effective_month: this_month
    ) { |budget| budget.monthly_limit_cents = template[:monthly_limit_cents] }
  end

  restaurants_budget = budgets.find { |budget| budget.category.name == "Restaurants" }
  restaurants_budget.budget_alerts.active.first_or_create!(spent_cents: 11_609)

  user
end

[
  { preset: DemoUserPresets::ALL[0], institution_name: "Bank of America" },
  { preset: DemoUserPresets::ALL[1], institution_name: "Chase" },
  { preset: DemoUserPresets::ALL[2], institution_name: "Wells Fargo" }
].each do |entry|
  seed_demo_user!(name: entry[:preset][:name], password: entry[:preset][:password], institution_name: entry[:institution_name])
end

# Alex also connects a second bank - also "Wells Fargo", same as John's
# primary account; institution_name is just a display string, not a unique
# key, so reusing it across different users' accounts is fine. See the
# WELLS_FARGO_TRANSACTIONS_* comment above for why this one exists.
alex_slug = DemoUserPresets::ALL[0][:name].downcase
seed_demo_bank_account!(
  user: User.find_by!(email: DemoUserPresets::ALL[0][:name]),
  account_slug: "#{alex_slug}-wells-fargo",
  institution_name: "Wells Fargo",
  this_month_templates: WELLS_FARGO_TRANSACTIONS_THIS_MONTH,
  last_month_templates: WELLS_FARGO_TRANSACTIONS_LAST_MONTH
)

# The dashboard's spend/budget/trend panels all read from monthly_summaries
# (app/services/dashboard_data.rb), not transactions directly - that table is
# normally rebuilt nightly (NightlySummaryRebuildJob, config/recurring.yml).
# Seeding transactions alone leaves it empty, so rebuild it here too (same
# approach as loadtest/seed.rb).
NightlySummaryRebuildJob.perform_now
