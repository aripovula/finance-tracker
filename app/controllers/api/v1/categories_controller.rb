module Api
  module V1
    class CategoriesController < BaseController
      before_action :authenticate_user!

      def index
        categories = Category.order(:name)

        render_envelope(data: categories.map { |category| category_json(category) })
      end

      private

      def category_json(category)
        {
          id: category.id,
          name: category.name,
          plaid_category_id: category.plaid_category_id,
          parent_category_id: category.parent_category_id
        }
      end
    end
  end
end
