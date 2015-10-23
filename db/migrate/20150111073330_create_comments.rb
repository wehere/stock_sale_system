class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.integer :order_id
      t.integer :user_id
      t.text :content
      t.boolean :delete_flag

      t.timestamps
    end
  end
end
