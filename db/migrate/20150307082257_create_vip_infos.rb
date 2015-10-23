class CreateVipInfos < ActiveRecord::Migration
  def change
    create_table :vip_infos do |t|
      t.integer :company_id
      t.integer :vip_type
      t.date :valid_date

      t.timestamps
    end
  end
end
