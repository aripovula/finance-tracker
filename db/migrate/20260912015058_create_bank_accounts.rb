class CreateBankAccounts < ActiveRecord::Migration[8.1]
  def change
    create_table :bank_accounts do |t|
      t.references :user, null: false, foreign_key: true
      t.string :plaid_item_id, null: false
      t.string :plaid_access_token, null: false
      t.string :institution_name
      t.string :plaid_account_id, null: false
      t.string :mask

      t.timestamps
    end
    add_index :bank_accounts, :plaid_account_id, unique: true
  end
end
