require "rails_helper"

RSpec.describe "Dashboard", type: :feature do
  around { |example| travel_to(Date.new(2026, 9, 15)) { example.run } }

  it "shows this month's KPIs, an active budget alert, and the spending trend chart" do
    log_in_as(users(:one))

    expect(page).to have_content("Spent this month")
    expect(page).to have_content("$45.99")

    expect(page).to have_content("Dining")
    expect(page).to have_content("is over budget this month")
    expect(page).to have_content("$550.00")
    expect(page).to have_content("$500.00")

    expect(page).to have_content("Spending trend")
    expect(page).to have_content("Budget vs. actual")
    expect(page).to have_selector("svg")
  end
end
