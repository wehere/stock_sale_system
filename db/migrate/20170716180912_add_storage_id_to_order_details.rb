class AddStorageIdToOrderDetails < ActiveRecord::Migration[5.0]
  def change
    add_column :order_details, :storage_id, :integer, after: :supplier_id
  end
end
