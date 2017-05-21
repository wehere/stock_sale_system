class ExportTotalDayMoneyBySellerJob < ApplicationJob
  queue_as :default

  def perform(start_date, end_date, supplier_id)
    OrderDetail.export_total_day_money_by_seller start_date, end_date, supplier_id
  end
end
