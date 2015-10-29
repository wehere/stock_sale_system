class RenameFromIdToSellerIdOfPurchaseOrders < ActiveRecord::Migration
  def change
    rename_column :purchase_orders, :from_id, :seller_id
  end
end
