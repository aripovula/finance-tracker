require "rails_helper"

RSpec.describe "Budget alert dismissal", type: :feature do
  it "removes an over-budget alert from the dashboard without a full page reload" do
    log_in_as(users(:one))

    expect(page).to have_content("Dining")
    expect(page).to have_content("is over budget this month")

    click_button "Dismiss"

    expect(page).to have_no_content("is over budget this month")
    expect(budget_alerts(:one).reload.dismissed_at).to be_present
  end
end
