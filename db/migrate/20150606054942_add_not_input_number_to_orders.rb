class AddNotInputNumberToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :not_input_number, :integer
  end
end
