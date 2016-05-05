class CreateEmployeeFoods < ActiveRecord::Migration
  def change
    create_table :employee_foods do |t|
      t.integer :product_id
      t.integer :supplier_id
      t.boolean :is_valid

      t.timestamps null: false
    end
  end
end
