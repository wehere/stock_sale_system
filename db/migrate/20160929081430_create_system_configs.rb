class CreateSystemConfigs < ActiveRecord::Migration
  def change
    create_table :system_configs do |t|
      t.string :k
      t.string :v

      t.timestamps null: false
    end
  end
end
