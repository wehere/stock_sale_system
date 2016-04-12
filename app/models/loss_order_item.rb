class LossOrderItem < ActiveRecord::Base

  belongs_to :loss_price

  #     loss_order_id: loss_order.id,
  #     product_id: loss_price.product_id,
  #     real_weight: real_weight,
  #     loss_price_id: loss_price.id
  def self.create_and_update_order_detail options
    self.transaction do
      loss_price = LossPrice.find(options[:loss_price_id])
      loss_order = LossOrder.find(options[:loss_order_id])
      product = loss_price.product
      BusinessException.raise "#{product.chinese_name}的数量必须是数值且不可以为0" if options[:real_weight].to_f == 0.0
      # 创建loss_order_item
      loss_order_item = LossOrderItem.new loss_order_id: options[:loss_order_id],
                                          product_id: loss_price.product_id,
                                          real_weight: options[:real_weight],
                                          price: loss_price.price,
                                          money: (options[:real_weight].to_f*loss_price.price).round(2),
                                          loss_price_id: loss_price.id,
                                          true_spec: loss_price.true_spec
      loss_order_item.save!
      # 创建order_details
      order_detail =
      OrderDetail.new supplier_id: loss_price.supplier_id,
                      related_company_id: loss_order.seller_id,
                      order_id: loss_order.id,
                      detail_type: loss_order.loss_type,
                      detail_date: loss_order.loss_date,
                      item_id: loss_order_item.id,
                      product_id: loss_price.product_id,
                      price: loss_price.price,
                      real_weight: loss_order_item.real_weight,
                      money: loss_order_item.money,
                      delete_flag: 0,
                      true_spec: loss_price.true_spec,
                      memo: loss_order.memo
      order_detail.save!
      # 更新stock
      stock = Stock.find_or_create_by(general_product_id: product.general_product.id,
                          storage_id: loss_order.storage_id,
                          supplier_id: loss_order.supplier_id
      )
      old_weight = stock.real_weight||0.0
      stock.real_weight = old_weight - loss_price.ratio*loss_order_item.real_weight
      stock.save!
    end
  end
end