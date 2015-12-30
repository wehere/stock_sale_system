class AddIsValidToGeneralProducts < ActiveRecord::Migration
  def change
    add_column :general_products, :is_valid, :boolean, default: true
  end
end
