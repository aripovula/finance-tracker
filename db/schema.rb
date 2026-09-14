# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_09_14_014335) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "bank_accounts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "institution_name"
    t.string "mask"
    t.string "plaid_access_token", null: false
    t.string "plaid_account_id", null: false
    t.string "plaid_item_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["plaid_account_id"], name: "index_bank_accounts_on_plaid_account_id", unique: true
    t.index ["user_id"], name: "index_bank_accounts_on_user_id"
  end

  create_table "budgets", force: :cascade do |t|
    t.bigint "category_id", null: false
    t.datetime "created_at", null: false
    t.date "effective_month", null: false
    t.integer "monthly_limit_cents", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["category_id"], name: "index_budgets_on_category_id"
    t.index ["user_id", "category_id", "effective_month"], name: "index_budgets_on_user_category_month", unique: true
    t.index ["user_id"], name: "index_budgets_on_user_id"
  end

  create_table "categories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "parent_category_id"
    t.string "plaid_category_id"
    t.datetime "updated_at", null: false
    t.index ["parent_category_id"], name: "index_categories_on_parent_category_id"
  end

  create_table "refresh_tokens", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.datetime "revoked_at"
    t.string "token_digest", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["token_digest"], name: "index_refresh_tokens_on_token_digest", unique: true
    t.index ["user_id"], name: "index_refresh_tokens_on_user_id"
  end

  create_table "transactions", force: :cascade do |t|
    t.integer "amount_cents", null: false
    t.bigint "bank_account_id", null: false
    t.bigint "category_id"
    t.datetime "created_at", null: false
    t.string "merchant_name"
    t.string "plaid_transaction_id", null: false
    t.datetime "posted_at"
    t.jsonb "raw_payload"
    t.string "status", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.index ["bank_account_id"], name: "index_transactions_on_bank_account_id"
    t.index ["category_id"], name: "index_transactions_on_category_id"
    t.index ["plaid_transaction_id"], name: "index_transactions_on_plaid_transaction_id", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "password_digest"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "bank_accounts", "users"
  add_foreign_key "budgets", "categories"
  add_foreign_key "budgets", "users"
  add_foreign_key "categories", "categories", column: "parent_category_id"
  add_foreign_key "refresh_tokens", "users"
  add_foreign_key "transactions", "bank_accounts"
  add_foreign_key "transactions", "categories"
end
