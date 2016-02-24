class AddExceptCompanyIdsToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :except_company_ids, :string, default: '0'
  end
end
