class CreateVipAuthorities < ActiveRecord::Migration
  def change
    create_table :vip_authorities do |t|
      t.integer :vip_type
      t.integer :customer_count
      t.integer :print_able_per_day_count
      t.integer :product_count

      t.timestamps
    end
  end
end
