class AddSupplierIdToChecks < ActiveRecord::Migration[5.0]
  def change
    add_column :checks, :supplier_id, :integer, after: :id
  end
end
