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

  def self.export_stocks start_date, end_date, supplier_id
    order_details = OrderDetail.where("delete_flag is null or delete_flag = 0").where(supplier_id: supplier_id)
    order_details = order_details.where("start_date>= ?", start_date.to_time.change(hour:0,min:0,sec:0)) unless start_date.blank?
    order_details = order_details.where("end_date<=?", end_date.to_time.change(hour:23,min:59,sec:59)) unless end_date.blank?
    result = {}
    order_details.each do |order_detail|
      if result[order_detail.product_id].blank?
        if order_detail.detail_type == 2
          h = {}
          h[:sale_date] = order_detail.detail_date
          h[:purchase_date] = ''
          h[:sale_price] = order_detail.price
          h[:purchase_price] = 0
          h[:real_weight] = 0.0-order_detail.real_weight
          result[order_detail.product_id] = h
        elsif order_detail.detail_type == 1
          h = {}
          h[:sale_date] = ''
          h[:purchase_date] = order_detail.detail_date
          h[:sale_price] = 0
          h[:purchase_price] = order_detail.price
          h[:real_weight] = order_detail.real_weight
          result[order_detail.product_id] = h
        end
      else
        if order_detail.detail_type == 2
          h = result[order_detail.product_id]
          if order_detail.detail_date > h[:sale_date] && !order_detail.price.blank?
            h[:sale_date] = order_detail.detail_date
            h[:sale_price] = order_detail.price
          end
          h[:real_weight] -= order_detail.real_weight
        elsif order_detail.detail_type == 1
          h = result[order_detail.product_id]
          if order_detail.detail_date > h[:purchase_date] && !order_detail.price.blank?
            h[:purchase_date] = order_detail.detail_date
            h[:purchase_price] = order_detail.price
          end
          h[:real_weight] += order_detail.real_weight
        end
      end
    end
  end
end