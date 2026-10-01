require "rails_helper"

# Simulating an actual browser-triggered file download under Cuprite is
# fragile (Content-Disposition: attachment hands the response to Chrome's
# download manager, not the page, so there's nothing in `page` to assert
# against) and wouldn't be testing anything the request spec in
# spec/requests/transactions_spec.rb doesn't already cover more directly.
# This checks the one genuinely E2E-relevant thing: the link is on the page
# and points at the right URL.
RSpec.describe "Transactions CSV export", type: :feature do
  it "offers a link to download every transaction as CSV" do
    log_in_as(users(:one))
    visit transactions_path

    expect(page).to have_link("Export CSV", href: transactions_path(format: :csv))
  end
end
