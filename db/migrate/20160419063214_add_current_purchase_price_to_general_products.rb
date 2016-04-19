class AddCurrentPurchasePriceToGeneralProducts < ActiveRecord::Migration
  def change
    add_column :general_products, :current_purchase_price, :float, default: 0.0
  end
end
