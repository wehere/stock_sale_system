class CreateLossPrices < ActiveRecord::Migration
  def change
    create_table :loss_prices do |t|
      t.integer :supplier_id
      t.integer :seller_id
      t.boolean :is_used
      t.string :true_spec
      t.float :price
      t.integer :product_id
      t.float :ratio

      t.timestamps null: false
    end
  end
end
