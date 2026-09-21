module Api
  module V1
    class DashboardController < BaseController
      before_action :authenticate_user!

      def monthly_summary
        summaries = current_user.monthly_summaries.where(month: requested_month).includes(:category).order("categories.name")

        if stale?(summaries, public: false)
          render_envelope(data: summaries.map { |summary| summary_json(summary) })
        end
      end

      private

      def requested_month
        return Date.parse("#{params[:month]}-01") if params[:month].present?

        Date.current.beginning_of_month
      end

      def summary_json(summary)
        {
          category_id: summary.category_id,
          category_name: summary.category.name,
          month: summary.month,
          total_spent_cents: summary.total_spent_cents
        }
      end
    end
  end
end
