class AddPrePriceToPrices < ActiveRecord::Migration
  def change
    add_column :prices, :pre_price, :float
  end
end
