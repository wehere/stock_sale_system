class AddSortNumberToSellers < ActiveRecord::Migration
  def change
    add_column :sellers, :sort_number, :integer, default: 0
  end
end
