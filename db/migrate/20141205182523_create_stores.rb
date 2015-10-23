class CreateStores < ActiveRecord::Migration
  def change
    create_table :stores do |t|
      t.integer :company_id
      t.string :name

      t.timestamps
    end
  end
end
