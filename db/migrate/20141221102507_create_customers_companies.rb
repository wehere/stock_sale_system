class CreateCustomersCompanies < ActiveRecord::Migration
  def change
    create_table :customers_companies, id: false do |t|
      t.integer :customer_id
      t.integer :company_id

      t.timestamps
    end
  end
end
