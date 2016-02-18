class AddMinSpecsAndSubSpecToCompany < ActiveRecord::Migration
  def change
    add_column :companies, :min_specs, :string, limit: 500
    add_column :companies, :sub_specs, :string, limit: 500
  end
end
