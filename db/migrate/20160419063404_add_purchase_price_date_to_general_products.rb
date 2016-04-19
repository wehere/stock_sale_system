class AddPurchasePriceDateToGeneralProducts < ActiveRecord::Migration
  def change
    add_column :general_products, :purchase_price_date, :date
  end
end
