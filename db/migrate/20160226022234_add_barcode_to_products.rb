class AddBarcodeToProducts < ActiveRecord::Migration
  def change
    add_column :products, :barcode, :string
  end
end
