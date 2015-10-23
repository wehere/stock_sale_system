class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string :english_name
      t.string :chinese_name
      t.string :simple_abc
      t.string :spec

      t.timestamps
    end
  end
end
