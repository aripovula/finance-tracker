require "rails_helper"

RSpec.describe User, type: :model do
  it "is valid with email and password" do
    user = User.new(email: "new@example.com", password: "password123")
    expect(user).to be_valid
  end

  it "is invalid without email" do
    user = User.new(email: nil, password: "password123")
    expect(user).not_to be_valid
  end

  it "is invalid with duplicate email" do
    user = User.new(email: users(:one).email, password: "password123")
    expect(user).not_to be_valid
  end

  it "is invalid with malformed email" do
    user = User.new(email: "not-an-email", password: "password123")
    expect(user).not_to be_valid
  end

  it "authenticates with correct password" do
    expect(users(:one).authenticate("password123")).to be_truthy
  end

  it "does not authenticate with incorrect password" do
    expect(users(:one).authenticate("wrongpassword")).to be_falsey
  end
end
