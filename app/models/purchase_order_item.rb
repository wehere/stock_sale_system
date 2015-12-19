class PurchaseOrderItem < ActiveRecord::Base
  belongs_to :purchase_order
  belongs_to :purchase_price
  belongs_to :product

  def change_order_item real_weight, price, current_user
    supplier = current_user.company
    BusinessException.raise "#{current_user.user_name}还没关联给任何一个公司／供应商，不能做进出明细操作。" if supplier.blank?
    purchase_order = self.purchase_order
    BusinessException.raise "id为#{self.id}的品项没有对应的purchase_order抬头，不能做进出明细操作。" if purchase_order.blank?

    order_detail = OrderDetail.where(supplier_id: supplier.id, order_id: self.purchase_order_id, item_id: self.id).first
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
        ratio = self.purchase_price.ratio
        BusinessException.raise "id为#{self.price.id}的price，产品名为#{self.product.chinese_name},对应的相对于标准单位比率为空或为0，不能做库存更新操作" if ratio.blank? || ratio == 0
        stock.update_attributes real_weight: current_weight + (real_weight.to_f - order_detail.real_weight)*ratio
        order_detail.update_attributes real_weight: real_weight, price: price, money: (price.to_f * real_weight.to_f).round(2)
        self.update_attributes real_weight: real_weight, price: price, money: (price.to_f * real_weight.to_f).round(2)
      end
    end
  end
end