module Api
  module V1
    class TransactionsController < BaseController
      before_action :authenticate_user!

      def index
        scope = current_user_transactions
        scope = scope.where(category_id: params[:category_id]) if params[:category_id].present?
        scope = scope.where(posted_at: params[:from]..) if params[:from].present?
        scope = scope.where(posted_at: ..params[:to]) if params[:to].present?
        scope = scope.where("transactions.id > ?", params[:after]) if params[:after].present?

        transactions = scope.order(:id)

        render_envelope(data: transactions.as_json)
      end

      private

      def current_user_transactions
        Transaction.joins(:bank_account).where(bank_accounts: { user_id: current_user.id })
      end
    end
  end
end
