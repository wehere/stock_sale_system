class CreatePurchaseOrderItems < ActiveRecord::Migration
  def change
    create_table :purchase_order_items do |t|
      t.integer :purchase_order_id
      t.integer :product_id
      t.float :real_weight
      t.float :price
      t.float :money

      t.timestamps
    end
  end
end
