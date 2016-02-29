class AddCheckNegativeStockToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :check_negative_stock, :boolean, default: false
  end
end
