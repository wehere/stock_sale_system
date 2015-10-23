class AddReturnFlagToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :return_flag, :boolean
  end
end
