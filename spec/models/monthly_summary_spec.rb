require "rails_helper"

RSpec.describe MonthlySummary, type: :model do
  it "belongs to a user" do
    expect(monthly_summaries(:one).user).to eq(users(:one))
  end

  it "is invalid without a user" do
    summary = MonthlySummary.new(monthly_summaries_attributes.merge(user: nil))
    expect(summary).not_to be_valid
  end

  it "belongs to a category" do
    expect(monthly_summaries(:one).category).to eq(categories(:dining))
  end

  it "is invalid without a category" do
    summary = MonthlySummary.new(monthly_summaries_attributes.merge(category: nil))
    expect(summary).not_to be_valid
  end

  it "is invalid without a month" do
    summary = MonthlySummary.new(monthly_summaries_attributes.merge(month: nil))
    expect(summary).not_to be_valid
  end

  it "is invalid without total_spent_cents" do
    summary = MonthlySummary.new(monthly_summaries_attributes.merge(total_spent_cents: nil))
    expect(summary).not_to be_valid
  end

  it "is invalid with a duplicate user, category, and month" do
    summary = MonthlySummary.new(
      monthly_summaries_attributes.merge(
        user: monthly_summaries(:one).user, category: monthly_summaries(:one).category, month: monthly_summaries(:one).month
      )
    )
    expect(summary).not_to be_valid
  end

  def monthly_summaries_attributes
    {
      user: users(:one),
      category: categories(:dining),
      month: Date.new(2026, 10, 1),
      total_spent_cents: 5000
    }
  end
end
