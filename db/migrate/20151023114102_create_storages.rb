class CreateStorages < ActiveRecord::Migration
  def change
    create_table :storages do |t|
      t.integer :store_id
      t.string :name
      t.string :describe

      t.timestamps
    end
  end
end
