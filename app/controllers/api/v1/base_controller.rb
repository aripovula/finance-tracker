module Api
  module V1
    class BaseController < ActionController::API
      private

      def render_envelope(data: nil, errors: [], meta: {}, status: :ok)
        render json: { data: data, errors: errors, meta: meta }, status: status
      end
    end
  end
end
