class AddLocationToGeneralProducts < ActiveRecord::Migration
  def change
    add_column :general_products, :location, :string, limit: 500
    add_column :general_products, :memo, :string, limit: 1000
  end
end
