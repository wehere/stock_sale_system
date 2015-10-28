class RenameFromIdToSellerIdOfPurchasePrices < ActiveRecord::Migration
  def change
    rename_column :purchase_prices, :from_id, :seller_id
  end
end
