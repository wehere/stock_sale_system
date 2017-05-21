class ExportTotalDayMoneyByVendorJob < ApplicationJob
  queue_as :default

  def perform(start_date, end_date, supplier_id)
    Product.export_total_day_money_by_vendor start_date, end_date, supplier_id
  end
end
