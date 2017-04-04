class LossOrderItem < ActiveRecord::Base

  belongs_to :loss_order
  belongs_to :loss_price
  belongs_to :product

  def change_order_item real_weight, price, current_user
    LossOrderItem.transaction do
      supplier = current_user.company
      BusinessException.raise "#{current_user.user_name}还没关联给任何一个公司／供应商，不能做进出明细操作。" if supplier.blank?
      loss_order = self.loss_order
      BusinessException.raise "id为#{self.id}的品项没有对应的loss_order抬头，不能做进出明细操作。" if loss_order.blank?

      order_detail = OrderDetail.where(supplier_id: supplier.id, order_id: self.loss_order_id, item_id: self.id).where("delete_flag is null or delete_flag = 0").first
      unless order_detail.blank?
        if self.real_weight == real_weight.to_f
          unless price.blank?
            self.update_attributes price: price, money: (price.to_f * real_weight.to_f).round(2)
            order_detail.update_attributes price: price, money: (price.to_f * real_weight.to_f).round(2)
          end
        else
          store = current_user.store
          BusinessException.raise "#{current_user.user_name}还没有权限处理任何一个仓库，不能做库存更新操作。" if store.blank?
          storage = store.storage
          BusinessException.raise "门店#{store.name}还没有关联到任何仓库，不能做库存更新操作。" if storage.blank?
          general_product = self.product.general_product
          BusinessException.raise "产品#{product.chinese_name}还没有关联任何通用产品，不能做库存更新操作。" if general_product.blank?
          stock = Stock.find_or_create_by general_product_id: general_product.id,
                                          storage_id: storage.id,
                                          supplier_id: supplier.id
          current_weight = stock.real_weight || 0
          ratio = self.loss_price.ratio
          BusinessException.raise "id为#{self.price.id}的price，产品名为#{self.product.chinese_name},对应的相对于标准单位比率为空或为0，不能做库存更新操作" if ratio.blank? || ratio == 0
          stock.update_attributes real_weight: current_weight - (real_weight.to_f - order_detail.real_weight)*ratio
          order_detail.update_attributes real_weight: real_weight, price: price, money: (price.to_f * real_weight.to_f).round(2)
          self.update_attributes real_weight: real_weight, price: price, money: (price.to_f * real_weight.to_f).round(2)
        end
      end
    end
  end

  def delete_self current_user, true_delete
    # 找到明细，根据明细，将库存还原
    # 将明细置为无效
    # 根据true_delete删除自己
    LossOrderItem.transaction do
      loss_order = self.loss_order
      order_detail = OrderDetail.where(supplier_id: loss_order.supplier_id, order_id: loss_order.id, item_id: self.id).where("delete_flag is null or delete_flag = 0").first
      store = current_user.store
      BusinessException.raise "#{current_user.user_name}还没有权限处理任何一个仓库，不能做库存更新操作。" if store.blank?
      storage = store.storage
      BusinessException.raise "门店#{store.name}还没有关联到任何仓库，不能做库存更新操作。" if storage.blank?
      general_product = self.product.general_product
      BusinessException.raise "产品#{product.chinese_name}还没有关联任何通用产品，不能做库存更新操作。" if general_product.blank?
      stock = Stock.find_or_create_by general_product_id: general_product.id,
                                      storage_id: storage.id,
                                      supplier_id: loss_order.supplier_id
      current_weight = stock.real_weight || 0
      ratio = self.loss_price.ratio
      BusinessException.raise "id为#{self.loss_price.id}的loss_price，进货价，产品名为#{self.product.chinese_name},对应的相对于标准单位比率为空或为0，不能做库存更新操作" if ratio.blank? || ratio == 0
      detail_real_weight = order_detail.real_weight.blank? ? 0 : order_detail.real_weight
      stock.update_attributes real_weight: current_weight + detail_real_weight*ratio
      order_detail.update_attributes delete_flag: 1
      if true_delete
        self.destroy!
      end
    end
  end

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
