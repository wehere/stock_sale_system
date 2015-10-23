class AddSupplierIdToSellers < ActiveRecord::Migration
  def change
    add_column :sellers, :supplier_id, :integer
  end
end
