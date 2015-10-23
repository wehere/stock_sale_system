class AddPlanWeightAndPurchasePriceIdToPurchaseOrderItems < ActiveRecord::Migration
  def change
    add_column :purchase_order_items, :plan_weight, :string
    add_column :purchase_order_items, :purchase_price_id, :integer
  end
end
