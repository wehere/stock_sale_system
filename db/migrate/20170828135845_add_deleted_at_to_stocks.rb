class AddDeletedAtToStocks < ActiveRecord::Migration[5.0]
  def change
    add_column :stocks, :deleted_at, :datetime, after: :last_purchase_price, comment: '删除时间'
  end
end
