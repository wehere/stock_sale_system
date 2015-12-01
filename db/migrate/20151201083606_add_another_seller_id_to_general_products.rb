class AddAnotherSellerIdToGeneralProducts < ActiveRecord::Migration
  def change
    add_column :general_products, :another_seller_id, :integer
  end
end
