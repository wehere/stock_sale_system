class AddColumnSupplierIdToPrice < ActiveRecord::Migration
  def change
    add_column :prices, :supplier_id, :integer
    rename_column :prices, :company_id, :customer_id
  end
end
