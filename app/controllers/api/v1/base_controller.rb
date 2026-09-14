module Api
  module V1
    class BaseController < ActionController::API
      private

      def render_envelope(data: nil, errors: [], meta: {}, status: :ok)
        render json: { data: data, errors: errors, meta: meta }, status: status
      end

      def authenticate_user!
        payload = bearer_token && JsonWebToken.decode(bearer_token)
        @current_user = payload && User.find_by(id: payload[:user_id])

        render_envelope(errors: [ "Unauthorized" ], status: :unauthorized) unless @current_user
      end

      def bearer_token
        request.headers["Authorization"]&.split(" ")&.last
      end

      def current_user
        @current_user
      end
    end
  end
end
