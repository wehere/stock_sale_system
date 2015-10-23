class CreateCompanies < ActiveRecord::Migration
  def change
    create_table :companies do |t|
      t.string :simple_name
      t.string :full_name
      t.string :phone
      t.string :address

      t.timestamps
    end
  end
end
