class AddTotalAmountToOtherOrders < ActiveRecord::Migration[5.0]
  def change
    add_column :other_orders, :total_amount, :float
  end
end
