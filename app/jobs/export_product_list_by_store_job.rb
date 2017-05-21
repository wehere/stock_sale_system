class ExportProductListByStoreJob < ApplicationJob
  queue_as :default

  def perform(supplier_id, store_id)
    Product.export_product_list_by_store supplier_id, store_id
  end
end
