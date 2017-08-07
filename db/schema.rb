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

ActiveRecord::Schema.define(version: 20170807131622) do

  create_table "check_items", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "check_id"
    t.integer  "general_product_id"
    t.string   "product_name"
    t.string   "unit"
    t.float    "storage_quantity",   limit: 24
    t.float    "quantity",           limit: 24
    t.float    "profit_or_loss",     limit: 24
    t.integer  "check_item_type"
    t.string   "note"
    t.datetime "deleted_at"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  create_table "checks", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "supplier_id"
    t.integer  "storage_id"
    t.string   "category"
    t.integer  "creator_id"
    t.integer  "check_items_count"
    t.integer  "status"
    t.date     "checked_at",                     comment: "盘点日期"
    t.datetime "deleted_at"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  create_table "comments", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "order_id"
    t.integer  "user_id"
    t.text     "content",     limit: 65535
    t.boolean  "delete_flag"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "companies", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "simple_name"
    t.string   "full_name"
    t.string   "phone"
    t.string   "address"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "marks",                  limit: 1000, default: "未分类"
    t.string   "vendors",                limit: 2000, default: "未分配"
    t.string   "min_specs",              limit: 500
    t.string   "sub_specs",              limit: 500
    t.string   "except_company_ids",                  default: "0"
    t.string   "mail_address"
    t.boolean  "check_negative_stock",                default: false
    t.boolean  "use_sale_ratio",                      default: false
    t.boolean  "check_repeated_product",              default: false
  end

  create_table "customers_companies", id: false, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "customer_id"
    t.integer  "company_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "delete_flag"
  end

  create_table "delayed_jobs", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "priority",                 default: 0, null: false
    t.integer  "attempts",                 default: 0, null: false
    t.text     "handler",    limit: 65535,             null: false
    t.text     "last_error", limit: 65535
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree
  end

  create_table "ding_scores", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.date     "uploaded_at"
    t.integer  "rank"
    t.float    "health",            limit: 24
    t.float    "performance",       limit: 24
    t.float    "average_load_time", limit: 24
    t.float    "business",          limit: 24
    t.float    "quality",           limit: 24
    t.float    "security",          limit: 24
    t.float    "response_time",     limit: 24
    t.float    "rpm",               limit: 24
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  create_table "employee_foods", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.integer  "product_id"
    t.integer  "supplier_id"
    t.boolean  "is_valid"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "general_products", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.integer  "seller_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "supplier_id"
    t.string   "mini_spec"
    t.integer  "another_seller_id"
    t.boolean  "pass"
    t.boolean  "is_valid",                            default: true
    t.string   "vendor",                              default: "未分配"
    t.string   "location",               limit: 500
    t.string   "memo",                   limit: 1000
    t.string   "barcode"
    t.float    "current_purchase_price", limit: 24,   default: 0.0
    t.date     "purchase_price_date"
    t.boolean  "need_check",                          default: true
  end

  create_table "loss_order_items", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.integer  "loss_order_id"
    t.integer  "product_id"
    t.float    "real_weight",   limit: 24
    t.float    "price",         limit: 24
    t.float    "money",         limit: 24
    t.integer  "loss_price_id"
    t.string   "true_spec"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "loss_orders", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.integer  "storage_id"
    t.datetime "loss_date"
    t.integer  "user_id"
    t.boolean  "delete_flag",              default: false
    t.integer  "supplier_id"
    t.integer  "seller_id"
    t.integer  "loss_type"
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.string   "memo",        limit: 1000
  end

  create_table "loss_prices", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.integer  "supplier_id"
    t.integer  "seller_id"
    t.boolean  "is_used"
    t.string   "true_spec"
    t.float    "price",       limit: 24
    t.integer  "product_id"
    t.float    "ratio",       limit: 24
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "messages", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "customer_id"
    t.integer  "supplier_id"
    t.text     "content",         limit: 65535
    t.datetime "need_reach_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "month_inventories", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer  "year_month_id"
    t.integer  "storage_id"
    t.integer  "general_product_id"
    t.float    "real_weight",        limit: 24, default: 0.0
    t.integer  "supplier_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "order_details", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "supplier_id"
    t.integer  "storage_id"
    t.integer  "related_company_id"
    t.integer  "order_id"
    t.integer  "detail_type"
    t.datetime "detail_date"
    t.integer  "item_id"
    t.integer  "product_id"
    t.float    "price",              limit: 24
    t.string   "plan_weight"
    t.float    "real_weight",        limit: 24
    t.float    "money",              limit: 24
    t.boolean  "delete_flag"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "true_spec"
    t.string   "memo",               limit: 500
    t.index ["supplier_id", "delete_flag", "detail_date"], name: "supplier_id", using: :btree
  end

  create_table "order_items", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
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

  create_table "order_types", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "customer_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "supplier_id"
    t.boolean  "delete_flag"
  end

  create_table "orders", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
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
    t.boolean  "is_confirm"
  end

  create_table "other_orders", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "supplier_id"
    t.integer  "storage_id"
    t.integer  "check_id"
    t.datetime "io_at"
    t.integer  "creator_id"
    t.integer  "category"
    t.datetime "deleted_at"
    t.string   "note"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.float    "total_amount", limit: 24
  end

  create_table "price_change_histories", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "price_id"
    t.float    "from_price",  limit: 24
    t.float    "to_price",    limit: 24
    t.datetime "change_time"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "prices", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "year_month_id"
    t.integer  "customer_id"
    t.integer  "product_id"
    t.float    "price",                       limit: 24
    t.boolean  "is_used"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "true_spec"
    t.integer  "supplier_id"
    t.integer  "print_times",                            default: 0
    t.float    "ratio",                       limit: 24
    t.date     "according_purchase_date"
    t.date     "pre_according_purchase_date"
    t.float    "pre_price",                   limit: 24
  end

  create_table "print_order_notices", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "supplier_id"
    t.integer "customer_id"
    t.string  "notice",      limit: 2000
  end

  create_table "product_items", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "supplier_id"
    t.integer  "other_order_id"
    t.integer  "general_product_id"
    t.string   "product_name"
    t.float    "quantity",           limit: 24
    t.string   "unit"
    t.float    "price",              limit: 24
    t.float    "amount",             limit: 24
    t.datetime "deleted_at"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  create_table "products", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "english_name"
    t.string   "chinese_name"
    t.string   "simple_abc"
    t.string   "spec"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "supplier_id"
    t.integer  "general_product_id"
    t.integer  "print_times",                   default: 0
    t.string   "describe"
    t.boolean  "is_valid",                      default: true
    t.string   "mark",                          default: "未分类"
    t.string   "barcode"
    t.float    "sale_ratio",         limit: 24, default: 0.0
  end

  create_table "purchase_order_items", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "purchase_order_id"
    t.integer  "product_id"
    t.float    "real_weight",       limit: 24
    t.float    "price",             limit: 24
    t.float    "money",             limit: 24
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "plan_weight"
    t.integer  "purchase_price_id"
    t.string   "true_spec"
  end

  create_table "purchase_orders", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "storage_id"
    t.datetime "purchase_date"
    t.integer  "user_id"
    t.boolean  "delete_flag"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "supplier_id"
    t.integer  "seller_id"
    t.string   "memo",          limit: 500
  end

  create_table "purchase_prices", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "supplier_id"
    t.integer  "seller_id"
    t.boolean  "is_used"
    t.string   "true_spec"
    t.float    "price",       limit: 24
    t.integer  "product_id"
    t.float    "ratio",       limit: 24
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "print_times"
  end

  create_table "roles", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.boolean  "is_valid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "roles_users", id: false, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "user_id", null: false
    t.integer "role_id", null: false
  end

  create_table "sellers", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.string   "shop_name"
    t.string   "phone"
    t.string   "address"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "supplier_id"
    t.integer  "sort_number", default: 0
    t.boolean  "delete_flag"
  end

  create_table "send_order_messages", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "supplier_id"
    t.integer  "customer_id"
    t.integer  "store_id"
    t.integer  "user_id"
    t.datetime "reach_date"
    t.integer  "order_type_id"
    t.text     "main_message",      limit: 65535
    t.text     "secondary_message", limit: 65535
    t.boolean  "is_valid",                        default: true
    t.boolean  "is_dealt",                        default: false
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
  end

  create_table "stocks", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "general_product_id"
    t.integer  "storage_id"
    t.float    "real_weight",         limit: 24
    t.float    "min_weight",          limit: 24
    t.float    "last_purchase_price", limit: 24
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "supplier_id"
  end

  create_table "storages", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "store_id"
    t.string   "name"
    t.string   "describe"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "stores", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "company_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "system_configs", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.string   "k"
    t.string   "v"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "test", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name", limit: 32
  end

  create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
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
    t.integer  "store_id"
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  end

  create_table "vip_authorities", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "vip_type"
    t.integer  "customer_count"
    t.integer  "print_able_per_day_count"
    t.integer  "product_count"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "vip_infos", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "company_id"
    t.integer  "vip_type"
    t.date     "valid_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "year_months", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "val"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "value"
  end

end
