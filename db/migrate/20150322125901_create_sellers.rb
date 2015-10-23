class CreateSellers < ActiveRecord::Migration
  def change
    create_table :sellers do |t|
      t.string :name
      t.string :shop_name
      t.string :phone
      t.string :address


      t.timestamps
    end
  end
end
