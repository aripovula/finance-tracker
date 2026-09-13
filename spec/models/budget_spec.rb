require "rails_helper"

RSpec.describe Budget, type: :model do
  it "belongs to a user" do
    expect(budgets(:one).user).to eq(users(:one))
  end

  it "is invalid without a user" do
    budget = Budget.new(budgets_attributes.merge(user: nil))
    expect(budget).not_to be_valid
  end

  it "belongs to a category" do
    expect(budgets(:one).category).to eq(categories(:dining))
  end

  it "is invalid without a category" do
    budget = Budget.new(budgets_attributes.merge(category: nil))
    expect(budget).not_to be_valid
  end

  it "is invalid without a monthly_limit_cents" do
    budget = Budget.new(budgets_attributes.merge(monthly_limit_cents: nil))
    expect(budget).not_to be_valid
  end

  it "is invalid without an effective_month" do
    budget = Budget.new(budgets_attributes.merge(effective_month: nil))
    expect(budget).not_to be_valid
  end

  it "is invalid with a duplicate user, category, and effective_month" do
    budget = Budget.new(budgets_attributes.merge(user: budgets(:one).user, category: budgets(:one).category, effective_month: budgets(:one).effective_month))
    expect(budget).not_to be_valid
  end

  def budgets_attributes
    {
      user: users(:one),
      category: categories(:dining),
      monthly_limit_cents: 10000,
      effective_month: Date.new(2026, 10, 1)
    }
  end
end
