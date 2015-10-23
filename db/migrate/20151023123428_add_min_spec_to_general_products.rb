class AddMinSpecToGeneralProducts < ActiveRecord::Migration
  def change
    add_column :general_products, :mini_spec, :string
  end
end
