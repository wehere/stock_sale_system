class CreatePrices < ActiveRecord::Migration
  def change
    create_table :prices do |t|
      t.integer :year_month_id
      t.integer :company_id
      t.integer :product_id
      t.float :price
      t.boolean :is_used

      t.timestamps
    end
  end
end
