class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.integer :company_id
      t.integer :store_id
      t.integer :order_type_id
      t.date :reach_order_date
      t.date :send_order_date

      t.timestamps
    end
  end
end
