class CategorizerConsumer < ApplicationConsumer
  def consume
    messages.each { |message| process(message.payload) }
  end

  private

  def process(payload)
    return unless payload["webhook_type"] == "TRANSACTIONS"

    bank_account = BankAccount.find_by(plaid_item_id: payload["item_id"])
    return unless bank_account

    TransactionSyncService.new.call(bank_account)
    categorize(bank_account)
  end

  def categorize(bank_account)
    bank_account.transactions.where(category_id: nil).find_each do |transaction|
      detailed = transaction.raw_payload&.dig("personal_finance_category", "detailed")
      next unless detailed

      category = Category.find_by("lower(plaid_category_id) = ?", detailed.downcase)
      transaction.update!(category: category) if category
    end
  end
end
