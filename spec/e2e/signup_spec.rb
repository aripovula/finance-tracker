require "rails_helper"

RSpec.describe "Sign up", type: :feature do
  it "lets a visitor create an account and then log in with it" do
    visit signup_path

    fill_in "Username", with: "newvisitor"
    fill_in "Password", with: "visitorpass1"
    click_button "Sign up"

    expect(page).to have_current_path(login_path)
    expect(page).to have_content("Account created")

    fill_in "Username", with: "newvisitor"
    fill_in "Password", with: "visitorpass1"
    click_button "Sign in"

    expect(page).to have_content("Dashboard")
  end

  it "shows an error when the username is already taken" do
    visit signup_path

    fill_in "Username", with: users(:one).email
    fill_in "Password", with: "visitorpass1"
    click_button "Sign up"

    expect(page).to have_current_path(signup_path)
    expect(page).to have_content("has already been taken")
  end
end
