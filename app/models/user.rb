class User < ApplicationRecord
  has_secure_password
  has_many :bank_accounts
  has_many :budgets
  has_many :budget_alerts, through: :budgets
  has_many :monthly_summaries
  has_many :refresh_tokens

  # Despite the column name, this doubles as a plain username: sign-up
  # (app/controllers/registrations_controller.rb) deliberately has no email
  # field, so this can't be format-validated as an email address. Kept named
  # "email" rather than renamed, since the login/API params and dozens of
  # existing specs already key off it.
  validates :email, presence: true, uniqueness: true
end
