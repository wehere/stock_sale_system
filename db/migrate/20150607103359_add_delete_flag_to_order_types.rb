class AddDeleteFlagToOrderTypes < ActiveRecord::Migration
  def change
    add_column :order_types, :delete_flag, :boolean
  end
end
