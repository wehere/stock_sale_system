class AddSupplierIdToStocks < ActiveRecord::Migration
  def change
    add_column :stocks, :supplier_id, :integer
  end
end
