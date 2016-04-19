class AddAccordingPurchaseDate < ActiveRecord::Migration
  def change
    add_column :prices, :according_purchase_date, :date
  end
end
