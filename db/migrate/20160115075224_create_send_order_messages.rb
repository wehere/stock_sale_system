class CreateSendOrderMessages < ActiveRecord::Migration
  def change
    create_table :send_order_messages do |t|
      t.integer :supplier_id
      t.integer :customer_id
      t.integer :store_id
      t.integer :user_id
      t.datetime :reach_date
      t.integer :order_type_id
      t.text :main_message
      t.text :secondary_message
      t.boolean :is_valid, default: true
      t.boolean :is_dealt, default: false

      t.timestamps null:false
    end
  end
end
