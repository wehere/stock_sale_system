class AddPrintTimesToProducts < ActiveRecord::Migration
  def change
    add_column :products, :print_times, :integer, default: 0
  end
end
