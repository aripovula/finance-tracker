require "rails_helper"

RSpec.describe "Login", type: :feature do
  it "lets a user log in with valid credentials and reach the dashboard" do
    visit login_path

    fill_in "Email", with: users(:one).email
    fill_in "Password", with: "password123"
    click_button "Log in"

    expect(page).to have_current_path(root_path)
    expect(page).to have_content("Dashboard")
    expect(page).to have_content("How this works")
  end

  it "shows an error and stays on the login page for invalid credentials" do
    visit login_path

    fill_in "Email", with: users(:one).email
    fill_in "Password", with: "wrong-password"
    click_button "Log in"

    expect(page).to have_current_path(login_path)
    expect(page).to have_content("Invalid email or password")
  end
end
