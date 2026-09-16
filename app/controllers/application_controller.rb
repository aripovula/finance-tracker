class ApplicationController < ActionController::Base
  include Authenticatable

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found

  private

  def render_not_found
    flash[:alert] = "Record not found"
    redirect_to root_path
  end
end
