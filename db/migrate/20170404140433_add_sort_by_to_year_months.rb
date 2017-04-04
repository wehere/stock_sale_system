class AddSortByToYearMonths < ActiveRecord::Migration
  def change
    add_column :year_months, :value, :integer
  end
end
