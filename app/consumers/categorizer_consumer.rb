class CategorizerConsumer < ApplicationConsumer
  # Plaid's own Sandbox model files some narrations into a generic "_OTHER_"
  # bucket at low confidence even though the merchant name is recognizable.
  # Refine those specific cases into a more precise, already-seeded category.
  MERCHANT_NAME_REFINEMENTS = {
    /INTRST PYMNT/i => "INCOME_INTEREST_EARNED",
    /AUTOMATIC PAYMENT.*THANK/i => "LOAN_PAYMENTS_CREDIT_CARD_PAYMENT"
  }.freeze

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

      plaid_category_id = refine(transaction, detailed)
      category = Category.find_by("lower(plaid_category_id) = ?", plaid_category_id.downcase)
      transaction.update!(category: category) if category
    end
  end

  def refine(transaction, detailed)
    match = MERCHANT_NAME_REFINEMENTS.find { |pattern, _| transaction.merchant_name.to_s.match?(pattern) }
    match ? match.last : detailed
  end
end
