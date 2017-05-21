class ExportProductInOutJob < ApplicationJob
  queue_as :default

  def perform(start_date, end_date, supplier_id)
    Product.export_product_in_out start_date, end_date, supplier_id
  end
end
