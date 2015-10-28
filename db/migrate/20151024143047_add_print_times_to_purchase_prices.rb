class AddPrintTimesToPurchasePrices < ActiveRecord::Migration
  def change
    add_column :purchase_prices, :print_times, :integer
  end
end
