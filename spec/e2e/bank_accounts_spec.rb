require "rails_helper"

RSpec.describe "Bank accounts", type: :feature do
  it "lists the user's connected bank accounts" do
    log_in_as(users(:one))
    visit bank_accounts_path

    expect(page).to have_content(bank_accounts(:one).institution_name)
    expect(page).to have_content(bank_accounts(:one).mask)
  end

  it "shows an empty state for a user with no connected bank accounts" do
    no_accounts_user = User.create!(email: "empty@example.com", password: "password123")

    log_in_as(no_accounts_user)
    visit bank_accounts_path

    expect(page).to have_content("No bank accounts connected yet.")
  end
end
