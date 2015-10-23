class AddColumnDeleteFlagToCustomersCompanies < ActiveRecord::Migration
  def change
    add_column :customers_companies, :delete_flag, :boolean
  end
end
