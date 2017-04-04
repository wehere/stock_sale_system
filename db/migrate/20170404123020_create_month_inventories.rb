class CreateMonthInventories < ActiveRecord::Migration
  def change
    create_table :month_inventories do |t|
      t.integer :year_month_id
      t.integer :storage_id
      t.integer :general_product_id
      t.float :real_weight, default: 0.0
      t.integer :supplier_id
    end
  end
end
