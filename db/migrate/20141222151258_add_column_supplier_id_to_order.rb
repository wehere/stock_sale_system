class AddColumnSupplierIdToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :supplier_id, :integer
    rename_column :orders, :company_id, :customer_id
  end
end
