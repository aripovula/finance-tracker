require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "valid with email and password" do
    user = User.new(email: "new@example.com", password: "password123")
    assert user.valid?
  end

  test "invalid without email" do
    user = User.new(email: nil, password: "password123")
    assert_not user.valid?
  end

  test "invalid with duplicate email" do
    user = User.new(email: users(:one).email, password: "password123")
    assert_not user.valid?
  end

  test "invalid with malformed email" do
    user = User.new(email: "not-an-email", password: "password123")
    assert_not user.valid?
  end

  test "authenticates with correct password" do
    assert users(:one).authenticate("password123")
  end

  test "does not authenticate with incorrect password" do
    assert_not users(:one).authenticate("wrongpassword")
  end
end
