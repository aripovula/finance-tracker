class SessionsController < ApplicationController
  before_action :redirect_if_logged_in, only: %i[new create]

  def new
  end

  def create
    user = User.find_by(email: params[:email])

    if user&.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_to root_path
    else
      flash.now[:alert] = "Invalid email or password"
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    reset_session
    redirect_to login_path, notice: "Logged out"
  end

  private

  def redirect_if_logged_in
    redirect_to root_path if logged_in?
  end
end
