class AddPreAccordingPurchaseDateToPrices < ActiveRecord::Migration
  def change
    add_column :prices, :pre_according_purchase_date, :date
  end
end
