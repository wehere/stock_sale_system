class MonthInventory < ActiveRecord::Base

  belongs_to :year_month

  belongs_to :storage

  belongs_to :general_product

  belongs_to :supplier

  def self.init
    # Company.all_suppliers.each do |supplier|
      supplier = Company.find(52)
      OrderDetail.valid.where('order_details.detail_date < "2016-03-01"
      and order_details.supplier_id = ?', supplier.id).each do |order_detail|
        month_inventory = MonthInventory.find_or_create_by supplier_id: supplier.id,
                            general_product_id: order_detail.product.general_product_id,
                            year_month_id: 24,
                            storage_id: supplier.stores.first.storage.id
        case order_detail.detail_type
        when 1 # 入库
          purchase_order_item = PurchaseOrderItem.find(order_detail.item_id)
          month_inventory.real_weight += purchase_order_item.real_weight * purchase_order_item.purchase_price.ratio
          month_inventory.save!
        when 2 # 出库
          order_item = OrderItem.find(order_detail.item_id)
          month_inventory.real_weight -= order_item.real_weight * order_item.price.ratio
          month_inventory.save!
        when 3 # 损耗
          loss_order_item = LossOrderItem.find(order_detail.item_id)
          month_inventory.real_weight -= loss_order_item.real_weight * loss_order_item.loss_price.ratio
          month_inventory.save!
        end
      end
    # end
  end
end
