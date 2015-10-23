class AddColumnsUserNameAndTerminalPasswordToUsers < ActiveRecord::Migration
  def change
    add_column :users, :user_name, :string
    add_column :users, :terminal_password, :string
  end
end
