require "rails_helper"

RSpec.describe "Transactions", type: :feature do
  it "lists the user's transactions and shows transaction detail" do
    log_in_as(users(:one))
    visit transactions_path

    expect(page).to have_content(transactions(:one).merchant_name)
    expect(page).to have_content(transactions(:two).merchant_name)
    expect(page).to have_content(categories(:dining).name)

    click_link transactions(:one).merchant_name

    expect(page).to have_content(transactions(:one).merchant_name)
    expect(page).to have_content(categories(:dining).name)
    expect(page).to have_content(bank_accounts(:one).institution_name)
  end
end
