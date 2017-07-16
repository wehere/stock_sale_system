class AddCheckedAtToChecks < ActiveRecord::Migration[5.0]
  def change
    add_column :checks, :checked_at, :date, after: :status, comment: '盘点日期'
  end
end
