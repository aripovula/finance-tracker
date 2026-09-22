class AddFlaggedAnomalyAtToTransactions < ActiveRecord::Migration[8.1]
  def change
    add_column :transactions, :flagged_anomaly_at, :datetime
  end
end
