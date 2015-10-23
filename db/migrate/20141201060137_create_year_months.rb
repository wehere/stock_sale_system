class CreateYearMonths < ActiveRecord::Migration
  def change
    create_table :year_months do |t|
      t.string :val

      t.timestamps
    end
  end
end
