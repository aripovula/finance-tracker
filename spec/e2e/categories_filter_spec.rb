require "rails_helper"

RSpec.describe "Categories filter", type: :feature do
  it "filters the category list client-side, with no page reload" do
    log_in_as(users(:one))
    visit categories_path

    expect(page).to have_content(categories(:dining).name)
    expect(page).to have_content(categories(:restaurants).name)

    fill_in "Filter categories by name", with: "restaurant"

    expect(page).to have_selector("tr[data-name='#{categories(:restaurants).name.downcase}']", visible: :visible)
    expect(page).to have_no_selector("tr[data-name='#{categories(:dining).name.downcase}']", visible: :visible)
  end

  it "shows an empty state when nothing matches the filter" do
    log_in_as(users(:one))
    visit categories_path

    fill_in "Filter categories by name", with: "does-not-exist"

    expect(page).to have_content("No categories match the user's filter.")
  end
end
