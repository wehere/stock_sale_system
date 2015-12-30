class AddIsValidToProducts < ActiveRecord::Migration
  def change
    add_column :products, :is_valid, :boolean, default: true
  end
end
