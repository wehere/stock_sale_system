class AddMarkToProducts < ActiveRecord::Migration
  def change
    add_column :products, :mark, :string, default: '未分类'
  end
end
