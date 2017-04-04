class AddTimeStampsToMonthInventories < ActiveRecord::Migration
  def change
    add_timestamps :month_inventories, null: true
  end
end
