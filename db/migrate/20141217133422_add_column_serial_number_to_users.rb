class AddColumnSerialNumberToUsers < ActiveRecord::Migration
  def change
    add_column :users, :serial_number, :string
  end
end
