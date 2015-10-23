class OrderItem < ActiveRecord::Base
  belongs_to :order
  belongs_to :product
  belongs_to :price
  delegate :chinese_name, to: :product, prefix: true, allow_nil: true
  delegate :real_price, to: :price, prefix: false, allow_nil: false

  scope :valid_order_items, -> { where("order_items.delete_flag is null or order_items.delete_flag = 0") }

  validates_presence_of :product, message: '不能没有对应的产品。'
  validates_presence_of :price, message: '不能没有对应的价格。'
  validates_presence_of :order, message: '不能没有对应的单据。'

  def self.create_order_item option
    order_item = self.new option
    order_item.save!
    order_item.reload
    order_item.update_money
    order_item
  end

  def update_money
    self.update_attribute :money, (self.real_price*self.real_weight).round(2)
  end

  def change_price new_price
    self.price.update_attribute :price, new_price
  end

  def self.query_order_items product_name, order_start_date, order_end_date, customer_id, supplier_id
    sql = <<-EOF
      select * from order_items
      left join products on products.id = order_items.product_id
      left join orders on orders.id = order_items.order_id
      where products.`chinese_name` like '%#{product_name}%'
    EOF
    sql += " and orders.`reach_order_date` >= '#{order_start_date}' " unless order_start_date.blank?
    sql += " and orders.`reach_order_date` <= '#{order_end_date}' " unless order_end_date.blank?
    sql += " and orders.`customer_id` = #{customer_id} " unless customer_id.blank?
    sql += " and orders.`supplier_id` = #{supplier_id} " unless supplier_id.blank?
    sql += " and (orders.`delete_flag` is null or orders.`delete_flag` = 0 ) "

    OrderItem.find_by_sql(sql)
  end

  def self.find_null_price supplier_id
    sql = <<-EOF
      select order_items.* from order_items
      left join orders on orders.id = order_items.order_id
      left join prices on prices.id = order_items.price_id
      left join companies on companies.id= orders.customer_id

      where prices.price =0 and prices.is_used=1
      and (orders.delete_flag is null or orders.delete_flag = 0)
      and orders.supplier_id = #{supplier_id}
      and (order_items.delete_flag is null or order_items.delete_flag = 0)
      and orders.reach_order_date > '#{Time.now.to_date.last_month.at_beginning_of_month.to_s}'
    EOF
    OrderItem.find_by_sql(sql)
  end

  def self.common_query options

    BusinessException.raise "未指定供应商是谁！" if options[:supplier_id].blank?

    order_items = OrderItem.valid_order_items

    order_items = order_items.joins(:order) unless order_items.joins_values.include? :order

    order_items = order_items.where("orders.delete_flag is null or orders.delete_flag = 0")

    order_items = order_items.where("orders.supplier_id = ? ", options[:supplier_id])

    unless options[:start_date].blank?
      order_items = order_items.joins(:order) unless order_items.joins_values.include? :order
      start_date = options[:start_date].to_date.change(hour:0,min:0,sec:0)
      order_items = order_items.where("orders.reach_order_date >= ?", start_date)
    end

    unless options[:end_date].blank?
      order_items = order_items.joins(:order) unless order_items.joins_values.include? :order
      end_date = options[:end_date].to_date.change(hour:23,min:59,sec:59)
      order_items = order_items.where("orders.reach_order_date <= ?", end_date)
    end

    unless options[:customer_id].blank?
      order_items = order_items.joins(:order) unless order_items.joins_values.include? :order
      order_items = order_items.where("orders.customer_id = ?", options[:customer_id])
    end

    unless options[:not_customer_id].blank?
      order_items = order_items.joins(:order) unless order_items.joins_values.include? :order
      order_items = order_items.where("orders.customer_id <> ?", options[:not_customer_id])
    end

    order_items.order("orders.customer_id, orders.reach_order_date")

  end

  def change_delete_status
    self.update_attribute :delete_flag, !self.delete_flag?
  end

  def self.classify supplier_id, specified_date
    sellers = Company.find(supplier_id).sellers
    Spreadsheet.client_encoding = "UTF-8"
    book = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet name: '分菜单'
    format = Spreadsheet::Format.new border: :thin
    merge_format = Spreadsheet::Format.new align: :merge, horizontal_align: :center, border: :thin
    sheet1.merge_cells(0,0,0,4)
    sheet1.row(0).set_format(0, merge_format)
    sheet1.row(0)[0] = "胜兴#{specified_date}购货汇总"
    # order_items = OrderItem.joins(:order).where("(orders.delete_flag is null or orders.delete_flag = 0) and orders.supplier_id = ? and orders.reach_order_date = ?", supplier_id, specified_date)
    order_items_sql = <<-EOF
      SELECT `order_items`.*
      FROM `order_items`
      LEFT JOIN `orders` ON `orders`.`id` = `order_items`.`order_id`
      LEFT JOIN `products` ON `products`.`id` = `order_items`.`product_id`
      LEFT JOIN `general_products` ON `general_products`.`id` = `products`.`general_product_id`
      LEFT JOIN `sellers` ON `sellers`.`id` = `general_products`.`seller_id`
      WHERE ((orders.delete_flag is null or orders.delete_flag = 0) and orders.supplier_id = #{supplier_id} and orders.reach_order_date = '#{specified_date}')
      order by `sellers`.`sort_number`, `general_products`.id
    EOF
    order_items = OrderItem.find_by_sql(order_items_sql)
    temp_seller_id = -1
    temp_general_product_id = -1
    current_row = 0
    current_col = 0
    order_items.each do |order_item|
      # 输出卖货人名字
      t_seller = order_item.product.general_product.seller
      unless temp_seller_id == t_seller.id
        current_row += 3
        sheet1.row(current_row)[0] = t_seller.name
        sheet1.row(current_row+1)[0] = t_seller.shop_name
        temp_seller_id = t_seller.id
      end
      t_general_product = order_item.product.general_product
      BusinessException.raise "#{order_item.product.chinese_name}(id:#{order_item.product.id})没有对应的通用产品。" if t_general_product.blank?
      unless temp_general_product_id == t_general_product.id
        current_row += 2
        current_col = 0
        sheet1.row(current_row)[current_col] = t_general_product.name
        sheet1.row(current_row).set_format(current_col, format)
        current_col += 1
        sheet1.row(current_row)[current_col] = order_item.order.customer.simple_name[0,2] + ":" + order_item.order.store.name[0,2]
        sheet1.row(current_row).set_format(current_col, format)
        sheet1.row(current_row+1)[current_col] = order_item.plan_weight
        sheet1.row(current_row+1).set_format(current_col, format)
        current_col += 1
        temp_general_product_id = t_general_product.id
      else
        sheet1.row(current_row)[current_col] = order_item.order.customer.simple_name[0,2] + ":" + order_item.order.store.name[0,2]
        sheet1.row(current_row).set_format(current_col, format)
        sheet1.row(current_row+1)[current_col] = order_item.plan_weight
        sheet1.row(current_row+1).set_format(current_col, format)
        current_col += 1
      end
    end



    # current_row = 0
    # sellers.each do |seller|
    #   sheet1.row(current_row)[0] = seller.name
    #   current_row += 1
    #   seller.general_products.each do |general_product|
    #     some_order_items = order_items.joins(product: :general_product).where("general_products.id = ? ", general_product.id)
    #     current_col = 0
    #     sheet1.row(current_row)[current_col] = general_product.name
    #     sheet1.merge_cells(current_row,current_col,current_row+1,current_col)
    #     sheet1.row(current_row).set_format(current_col, merge_format)
    #     sheet1.row(current_row+1).set_format(current_col, merge_format)
    #     current_col += 1
    #     some_order_items.each do |s_o_i|
    #       sheet1.row(current_row)[current_col] = s_o_i.order.customer.simple_name
    #       sheet1.row(current_row+1)[current_col] = s_o_i.plan_weight
    #       current_col += 1
    #     end
    #     current_row += 2
    #   end
    #   current_row += 2
    # end
    file_path = specified_date.to_date.to_s(:db) + "_分菜单.xls"
    book.write file_path
    file_path
  end

end
