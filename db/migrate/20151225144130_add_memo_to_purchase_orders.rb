class AddMemoToPurchaseOrders < ActiveRecord::Migration
  def change
    add_column :purchase_orders, :memo, :string, limit: 500
  end
end
