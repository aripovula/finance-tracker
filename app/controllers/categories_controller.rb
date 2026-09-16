class CategoriesController < ApplicationController
  before_action :require_login

  def index
    @categories = Category.includes(:parent_category).order(:name)
  end
end
