class CreatePriceChangeHistories < ActiveRecord::Migration
  def change
    create_table :price_change_histories do |t|
      t.integer :price_id
      t.float :from_price
      t.float :to_price
      t.datetime :change_time
      t.integer :user_id

      t.timestamps
    end
  end
end
