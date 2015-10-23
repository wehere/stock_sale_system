class AddDeleteFlagToOrderItems < ActiveRecord::Migration
  def change
    add_column :order_items, :delete_flag, :boolean
  end
end
