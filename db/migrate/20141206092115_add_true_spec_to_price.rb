class AddTrueSpecToPrice < ActiveRecord::Migration
  def change
    add_column :prices, :true_spec, :string
  end
end
