require "test_helper"

class BudgetTest < ActiveSupport::TestCase
  test "belongs to a user" do
    assert_equal users(:one), budgets(:one).user
  end

  test "invalid without a user" do
    budget = Budget.new(budgets_attributes.merge(user: nil))
    assert_not budget.valid?
  end

  test "belongs to a category" do
    assert_equal categories(:dining), budgets(:one).category
  end

  test "invalid without a category" do
    budget = Budget.new(budgets_attributes.merge(category: nil))
    assert_not budget.valid?
  end

  test "invalid without a monthly_limit_cents" do
    budget = Budget.new(budgets_attributes.merge(monthly_limit_cents: nil))
    assert_not budget.valid?
  end

  test "invalid without an effective_month" do
    budget = Budget.new(budgets_attributes.merge(effective_month: nil))
    assert_not budget.valid?
  end

  test "invalid with a duplicate user, category, and effective_month" do
    budget = Budget.new(budgets_attributes.merge(user: budgets(:one).user, category: budgets(:one).category, effective_month: budgets(:one).effective_month))
    assert_not budget.valid?
  end

  private

  def budgets_attributes
    {
      user: users(:one),
      category: categories(:dining),
      monthly_limit_cents: 10000,
      effective_month: Date.new(2026, 10, 1)
    }
  end
end
