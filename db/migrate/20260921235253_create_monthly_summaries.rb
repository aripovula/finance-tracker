class CreateMonthlySummaries < ActiveRecord::Migration[8.1]
  def change
    create_table :monthly_summaries do |t|
      t.references :user, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: true
      t.date :month, null: false
      t.integer :total_spent_cents, null: false

      t.timestamps
    end

    add_index :monthly_summaries, [ :user_id, :category_id, :month ], unique: true, name: "index_monthly_summaries_on_user_category_month"
  end
end
