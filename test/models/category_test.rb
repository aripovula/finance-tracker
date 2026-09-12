require "test_helper"

class CategoryTest < ActiveSupport::TestCase
  test "valid without a parent_category" do
    assert categories(:dining).valid?
  end

  test "belongs to a parent_category" do
    assert_equal categories(:dining), categories(:restaurants).parent_category
  end

  test "lists its subcategories" do
    assert_equal [ categories(:restaurants) ], categories(:dining).subcategories
  end

  test "invalid without a name" do
    category = Category.new(name: nil)
    assert_not category.valid?
  end
end
