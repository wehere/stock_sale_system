class AddGeneralProductIdToProducts < ActiveRecord::Migration
  def change
    add_column :products, :general_product_id, :integer
  end
end
