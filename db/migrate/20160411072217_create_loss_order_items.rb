class CreateLossOrderItems < ActiveRecord::Migration
  def change
    create_table :loss_order_items do |t|
      t.integer :loss_order_id
      t.integer :product_id
      t.float :real_weight
      t.float :price
      t.float :money
      t.integer :loss_price_id
      t.string :true_spec

      t.timestamps null: false
    end
  end
end
