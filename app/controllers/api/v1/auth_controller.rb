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

      def login
        user = User.find_by(email: params[:email])

        if user&.authenticate(params[:password])
          render_envelope(data: AuthTokenService.new.issue_tokens(user))
        else
          render_envelope(errors: [ "Invalid email or password" ], status: :unauthorized)
        end
      end

      def refresh
        render_envelope(data: AuthTokenService.new.refresh(params[:refresh_token]))
      rescue ActiveRecord::RecordNotFound
        render_envelope(errors: [ "Invalid refresh token" ], status: :unauthorized)
      end

      private

      def user_params
        params.permit(:email, :password, :password_confirmation)
      end
    end
  end
end
