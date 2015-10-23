class AddRatioToPrices < ActiveRecord::Migration
  def change
    add_column :prices, :ratio, :float
  end
end
