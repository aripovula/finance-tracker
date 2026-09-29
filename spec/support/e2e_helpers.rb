module E2EHelpers
  # Turbo intercepts the login form submit and swaps the DOM via fetch(), so
  # there's no real browser navigation event for Cuprite's click_button to
  # wait on. Asserting on the post-login page here lets Capybara's own
  # polling confirm the redirect actually landed before the caller moves on -
  # without it, a later `visit` can race the in-flight Turbo response.
  def log_in_as(user, password: "password123")
    visit login_path

    fill_in "Email", with: user.email
    fill_in "Password", with: password
    click_button "Log in"

    expect(page).to have_content("Dashboard")
  end
end

RSpec.configure do |config|
  config.include E2EHelpers, type: :feature
end
