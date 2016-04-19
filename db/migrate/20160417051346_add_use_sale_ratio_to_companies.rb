class AddUseSaleRatioToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :use_sale_ratio, :boolean, default: 0
  end
end
