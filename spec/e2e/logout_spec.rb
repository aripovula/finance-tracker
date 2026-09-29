require "rails_helper"

RSpec.describe "Logout", type: :feature do
  it "ends the session and requires login again for protected pages" do
    log_in_as(users(:one))

    click_button "Log out"

    expect(page).to have_current_path(login_path)
    expect(page).to have_content("Logged out")

    visit budgets_path

    expect(page).to have_current_path(login_path)
    expect(page).to have_content("Please log in to continue")
  end
end
