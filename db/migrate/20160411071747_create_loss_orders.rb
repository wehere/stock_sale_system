class CreateLossOrders < ActiveRecord::Migration
  def change
    create_table :loss_orders do |t|
      t.integer :storage_id
      t.datetime :loss_date
      t.integer :user_id
      t.boolean :delete_flag, default: 0
      t.integer :supplier_id
      t.integer :seller_id
      t.integer :loss_type

      t.timestamps null: false
    end
  end
end
