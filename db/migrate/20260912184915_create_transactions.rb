class CreateTransactions < ActiveRecord::Migration[8.1]
  def change
    create_table :transactions do |t|
      t.references :bank_account, null: false, foreign_key: true
      t.references :category, foreign_key: true
      t.string :plaid_transaction_id, null: false
      t.integer :amount_cents, null: false
      t.string :merchant_name
      t.datetime :posted_at
      t.string :status, null: false, default: "pending"
      t.jsonb :raw_payload

      t.timestamps
    end
    add_index :transactions, :plaid_transaction_id, unique: true
  end
end
