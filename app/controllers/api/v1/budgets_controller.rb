module Api
  module V1
    class BudgetsController < BaseController
      before_action :authenticate_user!

      def index
        budgets = current_user.budgets.order(effective_month: :desc)

        render_envelope(data: budgets.map { |budget| budget_json(budget) })
      end

      private

      def budget_json(budget)
        {
          id: budget.id,
          category_id: budget.category_id,
          monthly_limit_cents: budget.monthly_limit_cents,
          effective_month: budget.effective_month
        }
      end
    end
  end
end
