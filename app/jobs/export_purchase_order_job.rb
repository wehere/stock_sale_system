class ExportPurchaseOrderJob < ApplicationJob
  queue_as :default

  def perform(start_date, end_date, supplier_id)
    PurchaseOrder.export_purchase_order start_date, end_date, supplier_id
  end
end
