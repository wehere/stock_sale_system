class AddDescribeToProducts < ActiveRecord::Migration
  def change
    add_column :products, :describe, :string
  end
end
