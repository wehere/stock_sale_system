class CreateChecks < ActiveRecord::Migration[5.0]
  def change
    create_table :checks do |t|
      t.integer :storage_id
      t.string :category
      t.integer :creator_id
      t.integer :check_items_count
      t.integer :status
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
