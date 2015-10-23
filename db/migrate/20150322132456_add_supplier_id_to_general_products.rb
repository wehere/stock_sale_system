class AddSupplierIdToGeneralProducts < ActiveRecord::Migration
  def change
    add_column :general_products, :supplier_id, :integer
  end
end
