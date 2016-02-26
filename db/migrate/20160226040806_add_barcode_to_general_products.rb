class AddBarcodeToGeneralProducts < ActiveRecord::Migration
  def change
    add_column :general_products, :barcode, :string
  end
end
