class AddPassToGeneralProducts < ActiveRecord::Migration
  def change
    add_column :general_products, :pass, :boolean
  end
end
