class ChangeColumnSendDateToNeedReachDateForMessages < ActiveRecord::Migration
  def change
    rename_column :messages, :send_date, :need_reach_date
  end
end
