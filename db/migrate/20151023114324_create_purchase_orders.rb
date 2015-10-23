class CreatePurchaseOrders < ActiveRecord::Migration
  def change
    create_table :purchase_orders do |t|
      t.integer :storage_id
      t.datetime :purchase_date
      t.integer :user_id
      t.boolean :delete_flag

      t.timestamps
    end
  end
end
