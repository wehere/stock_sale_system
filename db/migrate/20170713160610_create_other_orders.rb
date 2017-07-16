class CreateOtherOrders < ActiveRecord::Migration[5.0]
  def change
    create_table :other_orders do |t|
      t.integer :supplier_id
      t.integer :storage_id
      t.datetime :io_at
      t.integer :creator_id
      t.integer :category
      t.datetime :deleted_at
      t.text :note

      t.timestamps
    end
  end
end
