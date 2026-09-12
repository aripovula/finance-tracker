require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "authenticates with correct password" do
    assert users(:one).authenticate("password123")
  end

  test "does not authenticate with incorrect password" do
    assert_not users(:one).authenticate("wrongpassword")
  end
end
