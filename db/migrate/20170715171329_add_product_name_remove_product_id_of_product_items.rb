class AddProductNameRemoveProductIdOfProductItems < ActiveRecord::Migration[5.0]
  def change
    add_column :product_items, :product_name, :string, after: :general_product_id
    remove_column :product_items, :product_id
  end
end
