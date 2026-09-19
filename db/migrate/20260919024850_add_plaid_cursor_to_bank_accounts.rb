class AddPlaidCursorToBankAccounts < ActiveRecord::Migration[8.1]
  def change
    add_column :bank_accounts, :plaid_cursor, :string
  end
end
