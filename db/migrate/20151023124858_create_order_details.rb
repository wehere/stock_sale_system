class CreateOrderDetails < ActiveRecord::Migration
  def change
    create_table :order_details do |t|
      t.integer :supplier_id
      t.integer :related_company_id
      t.integer :order_id
      t.integer :detail_type
      t.datetime :detail_date
      t.integer :item_id
      t.integer :product_id
      t.float :price
      t.string :plan_weight
      t.float :real_weight
      t.float :money
      t.boolean :delete_flag

      t.timestamps
    end
  end
end
