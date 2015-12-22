class OrderDetail < ActiveRecord::Base
  belongs_to :product

  scope :valid, ->{where("delete_flag is null or delete_flag = 0")}

  def self.write_stock_from_start_to_end storage_id, supplier_id, start_id, end_id
    # self.transaction do
      self.valid.where("id between ? and ?", start_id, end_id).each do |order_detail|
        general_product = order_detail.product.general_product
        real_weight = order_detail.real_weight
        price = order_detail.price
        stock = Stock.find_or_create_by storage_id: storage_id,
                                        supplier_id: supplier_id,
                                        general_product_id: general_product.id
        ratio = 0
        if order_detail.detail_type == 1
          purchase_order_item = PurchaseOrderItem.find_by_id(order_detail.item_id)
          ratio = purchase_order_item.purchase_price.ratio
          BusinessException.raise "purchase_price_id: #{purchase_order_item.purchase_price.id} ,换算率为空或0" if ratio.blank? or ratio == 0
          stock.last_purchase_price = price
          c_weight = stock.real_weight||0.0
          stock.real_weight = (c_weight + real_weight * ratio).round(2)
        elsif order_detail.detail_type == 2
          order_item = OrderItem.find_by_id(order_detail.item_id)
          ratio = order_item.price.ratio
          BusinessException.raise "price_id: #{order_item.price.id} ,换算率为空或0" if ratio.blank? or ratio == 0
          c_weight = stock.real_weight||0.0
          stock.real_weight = (c_weight - real_weight * ratio).round(2)
        end
        stock.save!
      end
    # end
  end
end