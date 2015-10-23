class CreateOrderItems < ActiveRecord::Migration
  def change
    create_table :order_items do |t|
      t.integer :order_id
      t.integer :product_id
      t.integer :price_id
      t.string :plan_weight
      t.float :real_weight
      t.float :money

      t.timestamps
    end
  end
end
