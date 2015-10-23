class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.integer :customer_id
      t.integer :supplier_id
      t.text :content
      t.datetime :send_date

      t.timestamps
    end
  end
end
