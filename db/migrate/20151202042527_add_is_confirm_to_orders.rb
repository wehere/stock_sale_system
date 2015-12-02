class AddIsConfirmToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :is_confirm, :boolean
  end
end
