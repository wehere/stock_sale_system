class ExportOrderTotalForSpecifiedDaysJob < ApplicationJob
  queue_as :default

  def perform(start_date, end_date, customer_id, supplier_id, store_id)
    Order.export_order_total_for_specified_days start_date,
                                                end_date,
                                                customer_id,
                                                supplier_id,
                                                store_id
  end
end
