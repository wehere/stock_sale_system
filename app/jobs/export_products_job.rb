class ExportProductsJob < ApplicationJob
  queue_as :default

  def perform(company_id, customer_id, year_month_id)
    Product.export company_id, customer_id, year_month_id
  end
end
