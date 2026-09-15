module Api
  module V1
    class TransactionsController < BaseController
      before_action :authenticate_user!

      DEFAULT_LIMIT = 25
      MAX_LIMIT = 100

      def index
        scope = current_user_transactions
        scope = scope.where(category_id: params[:category_id]) if params[:category_id].present?
        scope = scope.where(posted_at: params[:from]..) if params[:from].present?
        scope = scope.where(posted_at: ..params[:to]) if params[:to].present?
        scope = scope.where("transactions.id > ?", params[:after]) if params[:after].present?

        transactions = scope.order(:id).limit(limit)

        render_envelope(
          data: transactions.map { |transaction| transaction_json(transaction) },
          meta: { next_cursor: transactions.last&.id }
        )
      end

      def show
        transaction = current_user_transactions.find(params[:id])

        render_envelope(data: transaction_json(transaction))
      rescue ActiveRecord::RecordNotFound
        render_envelope(errors: [ "Transaction not found" ], status: :not_found)
      end

      private

      def current_user_transactions
        Transaction.joins(:bank_account).where(bank_accounts: { user_id: current_user.id })
      end

      def limit
        requested = params[:limit].to_i
        return DEFAULT_LIMIT if requested <= 0

        [ requested, MAX_LIMIT ].min
      end

      def transaction_json(transaction)
        {
          id: transaction.id,
          bank_account_id: transaction.bank_account_id,
          category_id: transaction.category_id,
          amount_cents: transaction.amount_cents,
          merchant_name: transaction.merchant_name,
          posted_at: transaction.posted_at,
          status: transaction.status
        }
      end
    end
  end
end
