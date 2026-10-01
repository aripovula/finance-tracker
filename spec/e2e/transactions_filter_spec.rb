require "rails_helper"

RSpec.describe "Transactions filter", type: :feature do
  it "filters the transaction list by search text, client-side, with no page reload" do
    log_in_as(users(:one))
    visit transactions_path

    expect(page).to have_content(transactions(:one).merchant_name)
    expect(page).to have_content(transactions(:two).merchant_name)

    fill_in "Search transactions by merchant or category", with: "chipotle"

    expect(page).to have_content(transactions(:one).merchant_name)
    expect(page).to have_no_content(transactions(:two).merchant_name)
  end

  it "filters the transaction list by date range" do
    log_in_as(users(:one))
    visit transactions_path

    fill_in "Filter transactions posted on or after", with: transactions(:two).posted_at.to_date.iso8601

    expect(page).to have_content(transactions(:two).merchant_name)
    expect(page).to have_no_content(transactions(:one).merchant_name)
  end

  it "shows an empty state when nothing matches" do
    log_in_as(users(:one))
    visit transactions_path

    fill_in "Search transactions by merchant or category", with: "no-such-merchant"

    expect(page).to have_content("No transactions match the user's filters.")
  end
end
