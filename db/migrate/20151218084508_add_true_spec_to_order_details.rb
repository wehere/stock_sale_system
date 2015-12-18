class AddTrueSpecToOrderDetails < ActiveRecord::Migration
  def change
    add_column :order_details, :true_spec, :string
  end
end
