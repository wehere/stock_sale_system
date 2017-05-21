class ExportXlsOfPricesJob < ApplicationJob
  queue_as :default

  def perform(supplier_id, id, year_month_id)
    Price.export_xls_of_prices supplier_id, id, year_month_id
  end
end
