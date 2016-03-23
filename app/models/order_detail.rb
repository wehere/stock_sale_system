class OrderDetail < ActiveRecord::Base
  belongs_to :product

  ORDER_TYPE = {
      1 => '入库',
      2 => '出库',
      3 => '损耗'
  }

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
    order_details = order_details.where("detail_date>= ?", start_date.to_time.change(hour:0,min:0,sec:0)) unless start_date.blank?
    order_details = order_details.where("detail_date<=?", end_date.to_time.change(hour:23,min:59,sec:59)) unless end_date.blank?
    result = {}
    order_details.each do |order_detail|
      if result[order_detail.product.general_product_id].blank?
        if order_detail.detail_type == 2
          h = {}
          h[:sale_date] = order_detail.detail_date
          h[:purchase_date] = ''
          h[:sale_price] = order_detail.price
          h[:purchase_price] = 0
          ratio = OrderItem.find_by_id(order_detail.item_id).price.ratio||0.0 rescue 0.0
          h[:real_weight] = 0.0-(order_detail.real_weight||0)*ratio
          result[order_detail.product.general_product_id] = h
        elsif order_detail.detail_type == 1
          h = {}
          h[:sale_date] = ''
          h[:purchase_date] = order_detail.detail_date
          h[:sale_price] = 0
          h[:purchase_price] = order_detail.price
          ratio = PurchaseOrderItem.find_by_id(order_detail.item_id).purchase_price.ratio||0.0 rescue 0.0
          h[:real_weight] = (order_detail.real_weight||0)*ratio
          result[order_detail.product.general_product_id] = h
        else
          h = {}
          ratio = 1.0
          h[:real_weight] = 0.0 - (order_detail.real_weight||0)*ratio
        end
      else
        if order_detail.detail_type == 2
          h = result[order_detail.product.general_product_id]
          if h[:sale_date].blank? || !order_detail.price.blank? && !order_detail.detail_date.blank? && order_detail.detail_date.to_date > h[:sale_date].to_date
            h[:sale_date] = order_detail.detail_date
            h[:sale_price] = order_detail.price
          end
          ratio = OrderItem.find_by_id(order_detail.item_id).price.ratio||0.0 rescue 0.0
          h[:real_weight] -= (order_detail.real_weight||0)*ratio
        elsif order_detail.detail_type == 1
          h = result[order_detail.product.general_product_id]
          if h[:purchase_date].blank? || !order_detail.detail_date.blank? && !order_detail.price.blank? && order_detail.detail_date.to_date > h[:purchase_date].to_date
            h[:purchase_date] = order_detail.detail_date
            h[:purchase_price] = order_detail.price
          end
          ratio = PurchaseOrderItem.find_by_id(order_detail.item_id).purchase_price.ratio||0.0 rescue 0.0
          h[:real_weight] += (order_detail.real_weight||0)*ratio
        elsif order_detail.detail_type == 3 or order_detail.detail_type == 4
          h = result[order_detail.product.general_product_id]
          ratio = 1.0
          h[:real_weight] -= (order_detail.real_weight||0)*ratio
        end
      end
    end
    result
    Spreadsheet.client_encoding = 'UTF-8'
    book = Spreadsheet::Workbook.new
    in_center = Spreadsheet::Format.new horizontal_align: :center, vertical_align: :center, border: :thin
    in_left = Spreadsheet::Format.new horizontal_align: :left, border: :thin
    sheet = book.create_worksheet name: '库存'
    current_row = 0
    sheet.row(current_row).push '品名', '单位', '价格', '库存量'
    current_row += 1
    sum = 0.0
    result.each do |key, value|
      g_p = GeneralProduct.find_by_id(key)
      last_price = value[:purchase_price].blank? ? (value[:sale_price].blank? ? 0.0 : value[:sale_price]) : value[:purchase_price]
      sheet.row(current_row).push g_p.name, g_p.mini_spec, last_price, value[:real_weight]
      sum += (last_price||0.0)*value[:real_weight]
      current_row += 1
    end
    sheet.row(current_row)[0] = "#{start_date}至#{end_date}汇总:#{sum.round(2)}"
    file_path = "#{Rails.root}/public/downloads/#{supplier_id}/#{start_date.to_date.to_s}至#{end_date.to_date.to_s}_#{Time.now.to_i}_库存数据.xls"
    book.write file_path
    file_path
  end
end