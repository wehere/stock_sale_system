class MonthInventory < ActiveRecord::Base

  belongs_to :year_month

  belongs_to :storage

  belongs_to :general_product

  belongs_to :supplier

  def self.init
    supplier = Company.find(52)
    # Company.all_suppliers.each do |supplier|
    YearMonth.where('value >= 201703 and value <= 201705').each do |year_month|
      MonthInventory.where(storage_id: supplier.stores.first.storage.id,
      year_month_id: YearMonth.find_by(val: YearMonth.chinese_month_format(year_month.beginning_date.last_month)).id,
      supplier_id: supplier.id).each do |m_i|
        mi = m_i.dup
        mi.year_month_id = year_month.id
        mi.save
      end

      OrderDetail.valid.where('order_details.detail_date <= ? and order_details.detail_date >= ?
      and order_details.supplier_id = ?', year_month.ending_date, year_month.beginning_date, supplier.id).find_each do |order_detail|
        month_inventory = MonthInventory.find_or_create_by supplier_id: supplier.id,
                            general_product_id: order_detail.product.general_product_id,
                            year_month_id: year_month.id,
                            storage_id: supplier.stores.first.storage.id
        case order_detail.detail_type
        when 1 # 入库
          purchase_order_item = PurchaseOrderItem.eager_load(:purchase_price).find(order_detail.item_id)
          month_inventory.real_weight += purchase_order_item.real_weight * purchase_order_item.purchase_price.ratio
          month_inventory.save!
        when 2 # 出库
          order_item = OrderItem.eager_load(:price).find(order_detail.item_id)
          month_inventory.real_weight -= order_item.real_weight * order_item.price.ratio
          month_inventory.save!
        when 3 # 损耗
          loss_order_item = LossOrderItem.eager_load(:loss_price).find(order_detail.item_id)
          month_inventory.real_weight -= loss_order_item.real_weight * loss_order_item.loss_price.ratio
          month_inventory.save!
        end
      end
    end
  end
end
