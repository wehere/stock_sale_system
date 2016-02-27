class AddMailAddressToCompany < ActiveRecord::Migration
  def change
    add_column :companies, :mail_address, :string
  end
end
