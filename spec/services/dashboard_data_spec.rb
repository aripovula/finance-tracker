require "rails_helper"

RSpec.describe DashboardData do
  describe "#spent_this_month_cents" do
    it "sums this month's monthly_summaries for the user" do
      travel_to monthly_summaries(:one).month + 10.days do
        data = described_class.new(users(:one))

        expect(data.spent_this_month_cents).to eq(monthly_summaries(:one).total_spent_cents)
      end
    end

    it "is zero when there are no summaries for the month" do
      travel_to monthly_summaries(:one).month + 10.days do
        data = described_class.new(users(:two))

        expect(data.spent_this_month_cents).to eq(0)
      end
    end
  end

  describe "#spent_last_month_cents" do
    it "sums last month's monthly_summaries for the user" do
      last_month = monthly_summaries(:one).month - 1.month
      MonthlySummary.create!(user: users(:one), category: categories(:restaurants), month: last_month, total_spent_cents: 2000)

      travel_to monthly_summaries(:one).month + 10.days do
        data = described_class.new(users(:one))

        expect(data.spent_last_month_cents).to eq(2000)
      end
    end
  end
end
