require "rails_helper"

RSpec.describe "Demo quick login", type: :feature do
  it "defaults to Alex with Alex's password already filled in" do
    visit login_path

    expect(page).to have_field("Username", with: "Alex")
    expect(page).to have_field("Password", with: DemoUserPresets::ALL[0][:password])
  end

  it "prefills the password for whichever preset user is selected" do
    visit login_path

    choose "Ann"

    expect(page).to have_field("Username", with: "Ann")
    expect(page).to have_field("Password", with: DemoUserPresets::ALL[1][:password])
  end

  it "logs in as the selected preset user" do
    visit login_path

    choose "John"
    click_button "Sign in"

    expect(page).to have_content("Dashboard")
  end
end
