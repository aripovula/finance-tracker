module Api
  module V1
    class PlaidController < BaseController
      def link_token
        user = User.find(params[:user_id])
        link_token = PlaidService.new.create_link_token(user)

        render_envelope(data: { link_token: link_token })
      rescue ActiveRecord::RecordNotFound
        render_envelope(errors: [ "User not found" ], status: :not_found)
      end
    end
  end
end
