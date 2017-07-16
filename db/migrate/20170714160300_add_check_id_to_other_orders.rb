class AddCheckIdToOtherOrders < ActiveRecord::Migration[5.0]
  def change
    add_column :other_orders, :check_id, :integer, after: :storage_id
  end
end
