require "rails_helper"

RSpec.describe BudgetAlert, type: :model do
  it "belongs to a budget" do
    expect(budget_alerts(:one).budget).to eq(budgets(:one))
  end

  it "is invalid without a budget" do
    alert = BudgetAlert.new(budget: nil, spent_cents: 1000)
    expect(alert).not_to be_valid
  end

  it "is invalid without spent_cents" do
    alert = BudgetAlert.new(budget: budgets(:one), spent_cents: nil)
    expect(alert).not_to be_valid
  end

  describe ".active" do
    it "excludes dismissed alerts" do
      dismissed = BudgetAlert.create!(budget: budgets(:one), spent_cents: 1000, dismissed_at: Time.current)

      expect(BudgetAlert.active).to include(budget_alerts(:one))
      expect(BudgetAlert.active).not_to include(dismissed)
    end
  end
end
