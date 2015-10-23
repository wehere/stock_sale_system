class AddFromIdToPurchaseOrders < ActiveRecord::Migration
  def change
    add_column :purchase_orders, :from_id, :integer
  end
end
