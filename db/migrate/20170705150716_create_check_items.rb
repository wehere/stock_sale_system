class CreateCheckItems < ActiveRecord::Migration[5.0]
  def change
    create_table :check_items do |t|
      t.integer :check_id
      t.integer :general_product_id
      t.string :product_name
      t.string :unit
      t.float :storage_quantity
      t.float :quantity
      t.float :profit_or_loss
      t.integer :type
      t.string :note
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
