class CreateBudgetAlerts < ActiveRecord::Migration[8.1]
  def change
    create_table :budget_alerts do |t|
      t.references :budget, null: false, foreign_key: true
      t.integer :spent_cents, null: false
      t.datetime :dismissed_at

      t.timestamps
    end
  end
end
