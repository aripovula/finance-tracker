module Api
  module V1
    class PlaidController < BaseController
      before_action :authenticate_user!

      def link_token
        link_token = PlaidService.new.create_link_token(current_user)

        render_envelope(data: { link_token: link_token })
      end

      def exchange_public_token
        bank_account = PlaidService.new.exchange_public_token(
          current_user, params[:public_token],
          institution_name: params[:institution_name],
          plaid_account_id: params[:account_id],
          mask: params[:mask]
        )

        render_envelope(
          data: { bank_account: { id: bank_account.id, institution_name: bank_account.institution_name, mask: bank_account.mask } },
          status: :created
        )
      rescue ActiveRecord::RecordInvalid => e
        render_envelope(errors: e.record.errors.full_messages, status: :unprocessable_entity)
      end
    end
  end
end
