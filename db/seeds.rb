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
