class AddMemoToOrderDetails < ActiveRecord::Migration
  def change
    add_column :order_details, :memo, :string, limit: 500
  end
end
