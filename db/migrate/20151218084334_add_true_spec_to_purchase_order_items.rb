class AddTrueSpecToPurchaseOrderItems < ActiveRecord::Migration
  def change
    add_column :purchase_order_items, :true_spec, :string
  end
end
