class CreatePurchasePrices < ActiveRecord::Migration
  def change
    create_table :purchase_prices do |t|
      t.integer :supplier_id
      t.integer :from_id
      t.boolean :is_used
      t.string :true_spec
      t.float :price
      t.integer :product_id
      t.float :ratio

      t.timestamps
    end
  end
end
