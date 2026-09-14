module Api
  module V1
    class AuthController < BaseController
      def register
        user = User.new(user_params)

        if user.save
          render_envelope(data: AuthTokenService.new.issue_tokens(user), status: :created)
        else
          render_envelope(errors: user.errors.full_messages, status: :unprocessable_entity)
        end
      end

      private

      def user_params
        params.permit(:email, :password, :password_confirmation)
      end
    end
  end
end
