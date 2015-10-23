class AddColumnSupplierIdToOrderType < ActiveRecord::Migration
  def change
    add_column :order_types, :supplier_id, :integer
    rename_column :order_types, :company_id, :customer_id
  end
end
