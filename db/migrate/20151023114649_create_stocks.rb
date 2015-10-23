class CreateStocks < ActiveRecord::Migration
  def change
    create_table :stocks do |t|
      t.integer :general_product_id
      t.integer :storage_id
      t.float :real_weight
      t.float :min_weight
      t.float :last_purchase_price

      t.timestamps
    end
  end
end
