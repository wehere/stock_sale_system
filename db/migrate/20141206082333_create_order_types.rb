class CreateOrderTypes < ActiveRecord::Migration
  def change
    create_table :order_types do |t|
      t.integer :company_id
      t.string :name

      t.timestamps
    end
  end
end
