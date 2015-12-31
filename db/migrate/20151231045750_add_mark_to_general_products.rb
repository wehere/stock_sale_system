class AddMarkToGeneralProducts < ActiveRecord::Migration
  def change
    add_column :general_products, :vendor, :string, default: '未分配'
    add_column :companies, :vendors, :string, limit: 2000, default: '未分配'
  end
end
