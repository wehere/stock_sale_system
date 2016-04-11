class AddSaleRatioToProducts < ActiveRecord::Migration
  def change
    add_column :products, :sale_ratio, :float, default: 0.0
  end
end
