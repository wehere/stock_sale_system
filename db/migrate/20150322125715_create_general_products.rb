class CreateGeneralProducts < ActiveRecord::Migration
  def change
    create_table :general_products do |t|
      t.string :name
      t.integer :seller_id

      t.timestamps
    end
  end
end
