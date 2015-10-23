# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150616120202) do

  create_table "comments", force: true do |t|
    t.integer  "order_id"
    t.integer  "user_id"
    t.text     "content"
    t.boolean  "delete_flag"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "companies", force: true do |t|
    t.string   "simple_name"
    t.string   "full_name"
    t.string   "phone"
    t.string   "address"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "customers_companies", id: false, force: true do |t|
    t.integer  "customer_id"
    t.integer  "company_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "delete_flag"
  end

  create_table "general_products", force: true do |t|
    t.string   "name"
    t.integer  "seller_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "supplier_id"
  end

  create_table "messages", force: true do |t|
    t.integer  "customer_id"
    t.integer  "supplier_id"
    t.text     "content"
    t.datetime "need_reach_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "order_items", force: true do |t|
    t.integer  "order_id"
    t.integer  "product_id"
    t.integer  "price_id"
    t.string   "plan_weight"
    t.float    "real_weight", limit: 24
    t.float    "money",       limit: 24
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "delete_flag"
  end

  create_table "order_types", force: true do |t|
    t.integer  "customer_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "supplier_id"
    t.boolean  "delete_flag"
  end

  create_table "orders", force: true do |t|
    t.integer  "customer_id"
    t.integer  "store_id"
    t.integer  "order_type_id"
    t.date     "reach_order_date"
    t.date     "send_order_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.boolean  "delete_flag"
    t.integer  "supplier_id"
    t.integer  "not_input_number"
    t.boolean  "return_flag"
  end

  create_table "price_change_histories", force: true do |t|
    t.integer  "price_id"
    t.float    "from_price",  limit: 24
    t.float    "to_price",    limit: 24
    t.datetime "change_time"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "prices", force: true do |t|
    t.integer  "year_month_id"
    t.integer  "customer_id"
    t.integer  "product_id"
    t.float    "price",         limit: 24
    t.boolean  "is_used"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "true_spec"
    t.integer  "supplier_id"
    t.integer  "print_times",              default: 0
  end

  create_table "print_order_notices", force: true do |t|
    t.integer "supplier_id"
    t.integer "customer_id"
    t.string  "notice",      limit: 2000
  end

  create_table "products", force: true do |t|
    t.string   "english_name"
    t.string   "chinese_name"
    t.string   "simple_abc"
    t.string   "spec"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "supplier_id"
    t.integer  "general_product_id"
    t.integer  "print_times",        default: 0
  end

  create_table "sellers", force: true do |t|
    t.string   "name"
    t.string   "shop_name"
    t.string   "phone"
    t.string   "address"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "supplier_id"
    t.integer  "sort_number", default: 0
  end

  create_table "stores", force: true do |t|
    t.integer  "company_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "test", force: true do |t|
    t.string "name", limit: 32
  end

  create_table "users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "company_id"
    t.string   "user_name"
    t.string   "terminal_password"
    t.string   "serial_number"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "vip_authorities", force: true do |t|
    t.integer  "vip_type"
    t.integer  "customer_count"
    t.integer  "print_able_per_day_count"
    t.integer  "product_count"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "vip_infos", force: true do |t|
    t.integer  "company_id"
    t.integer  "vip_type"
    t.date     "valid_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "year_months", force: true do |t|
    t.string   "val"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
