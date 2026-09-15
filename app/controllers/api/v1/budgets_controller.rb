module Api
  module V1
    class BudgetsController < BaseController
      before_action :authenticate_user!
      before_action :set_budget, only: [ :update ]

      def index
        budgets = current_user.budgets.order(effective_month: :desc)

        render_envelope(data: budgets.map { |budget| budget_json(budget) })
      end

      def create
        budget = current_user.budgets.new(budget_params)

        if budget.save
          render_envelope(data: budget_json(budget), status: :created)
        else
          render_envelope(errors: budget.errors.full_messages, status: :unprocessable_entity)
        end
      end

      def update
        if @budget.update(budget_params)
          render_envelope(data: budget_json(@budget))
        else
          render_envelope(errors: @budget.errors.full_messages, status: :unprocessable_entity)
        end
      end

      private

      def set_budget
        @budget = current_user.budgets.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render_envelope(errors: [ "Budget not found" ], status: :not_found)
      end

      def budget_params
        params.permit(:category_id, :monthly_limit_cents, :effective_month)
      end

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
