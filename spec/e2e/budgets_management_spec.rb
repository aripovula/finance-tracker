require "rails_helper"

RSpec.describe "Budget management", type: :feature do
  it "creates, edits, and deletes a budget" do
    category = categories(:interest_earned)

    log_in_as(users(:one))
    visit budgets_path

    click_link "New budget"
    select category.name, from: "Category"
    fill_in "Monthly limit ($)", with: "150.00"
    fill_in "Effective month", with: "2026-10"
    click_button "Create budget"

    expect(page).to have_content("Budget created")
    expect(page).to have_content("$150.00")

    within("tr", text: category.name) { click_link "Edit" }
    fill_in "Monthly limit ($)", with: "200.00"
    click_button "Save changes"

    expect(page).to have_content("Budget updated")
    expect(page).to have_content("$200.00")

    within("tr", text: category.name) do
      accept_confirm { click_button "Delete" }
    end

    expect(page).to have_content("Budget deleted")
    expect(page).to have_no_content(category.name)
  end
end
