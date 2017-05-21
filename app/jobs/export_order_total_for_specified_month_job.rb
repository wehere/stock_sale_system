class ExportOrderTotalForSpecifiedMonthJob < ApplicationJob
  queue_as :default

  def perform(start_date, end_date, supplier_id)
    Order.export_order_total_for_specified_month start_date,
                                                 end_date,
                                                 supplier_id
  end
end
