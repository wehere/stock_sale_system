class CreatePrintOrderNotice < ActiveRecord::Migration
  def change
    create_table :print_order_notices do |t|
      t.integer :supplier_id
      t.integer :customer_id
      t.string :notice, limit: 2000
    end
  end
end
