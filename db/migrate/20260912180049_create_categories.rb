class CreateCategories < ActiveRecord::Migration[8.1]
  def change
    create_table :categories do |t|
      t.string :name, null: false
      t.string :plaid_category_id
      t.references :parent_category, foreign_key: { to_table: :categories }

      t.timestamps
    end
  end
end
