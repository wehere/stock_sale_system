class AddMemoToLossOrders < ActiveRecord::Migration
  def change
    add_column :loss_orders, :memo, :string, limit: 1000
  end
end
