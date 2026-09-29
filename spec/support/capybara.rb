require "capybara/cuprite"
require "capybara/rspec"

# Cuprite drives real Chrome/Chromium over the Chrome DevTools Protocol - no
# Selenium, no npm/Node driver. Chrome's own internal sandbox needs a
# user/PID namespace most containers (CI runners, devcontainers, Codespaces)
# don't grant, so it just hangs without --no-sandbox until process_timeout
# kills it. This browser only ever visits Capybara's own localhost test
# server, never the open internet, so disabling its sandbox is low-risk here.
Capybara.server = :puma, { Silent: true }

# fill_in/click_button etc. match on a visible label by default; several views
# here only give inputs an aria-label (no visible <label>), so turn on
# Capybara's aria-label matching to find them.
Capybara.enable_aria_label = true

Capybara.register_driver(:cuprite) do |app|
  Capybara::Cuprite::Driver.new(
    app,
    window_size: [ 1200, 800 ],
    process_timeout: 15,
    browser_options: { "no-sandbox" => nil, "disable-gpu" => nil, "disable-dev-shm-usage" => nil }
  )
end

# Deliberately Capybara's own `type: :feature` (via capybara/rspec), not Rails/
# rspec-rails' `type: :system`. RSpec::Rails::SystemExampleGroup pulls in
# ActionDispatch::SystemTesting::TestHelpers::SetupAndTeardown, which reliably
# makes Ferrum's Chrome subprocess spawn hang (Ferrum::ProcessTimeoutError)
# even though the exact same browser/driver/options work fine standalone, after
# a full Rails boot, and even with a live Capybara/Puma server thread already
# running - the failure is isolated specifically to that Rails module, not to
# Cuprite, Chrome, or this app. Plain `type: :feature` sidesteps it entirely,
# so there's no Rails `driven_by` helper here - just set the default driver.
Capybara.default_driver = :cuprite
Capybara.javascript_driver = :cuprite
