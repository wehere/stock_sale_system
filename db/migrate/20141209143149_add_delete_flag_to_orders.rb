class AddDeleteFlagToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :delete_flag, :boolean
  end
end
