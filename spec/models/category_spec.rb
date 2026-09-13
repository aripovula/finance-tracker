require "rails_helper"

RSpec.describe Category, type: :model do
  it "is valid without a parent_category" do
    expect(categories(:dining)).to be_valid
  end

  it "belongs to a parent_category" do
    expect(categories(:restaurants).parent_category).to eq(categories(:dining))
  end

  it "lists its subcategories" do
    expect(categories(:dining).subcategories).to eq([ categories(:restaurants) ])
  end

  it "is invalid without a name" do
    category = Category.new(name: nil)
    expect(category).not_to be_valid
  end
end
