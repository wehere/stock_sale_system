class AddNeedCheckToGeneralProducts < ActiveRecord::Migration
  def change
    add_column :general_products, :need_check, :boolean, default: true
  end
end
