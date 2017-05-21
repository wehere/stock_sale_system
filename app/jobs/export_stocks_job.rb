class ExportStocksJob < ApplicationJob
  queue_as :default

  def perform(start_date, end_date, supplier_id)
    OrderDetail.export_stocks start_date, end_date, supplier_id
  end
end
