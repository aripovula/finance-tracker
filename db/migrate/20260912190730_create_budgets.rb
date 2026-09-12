class CreateBudgets < ActiveRecord::Migration[8.1]
  def change
    create_table :budgets do |t|
      t.references :user, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: true
      t.integer :monthly_limit_cents, null: false
      t.date :effective_month, null: false

      t.timestamps
    end
    add_index :budgets, [ :user_id, :category_id, :effective_month ], unique: true, name: "index_budgets_on_user_category_month"
  end
end
