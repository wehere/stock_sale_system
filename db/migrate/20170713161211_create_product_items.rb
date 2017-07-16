class CreateProductItems < ActiveRecord::Migration[5.0]
  def change
    create_table :product_items do |t|
      t.integer :supplier_id
      t.integer :other_order_id
      t.integer :product_id
      t.integer :general_product_id
      t.float :quantity
      t.string :unit
      t.float :price
      t.float :amount
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
