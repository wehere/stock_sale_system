class AddPrintTimesToPrices < ActiveRecord::Migration
  def change
    add_column :prices, :print_times, :integer, default: 0
  end
end
