class AddCheckRepeatedProductToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :check_repeated_product, :boolean, default: false
  end
end
