require "spreadsheet"
class Order < ActiveRecord::Base
  belongs_to :supplier, class_name: 'Company', foreign_key: 'supplier_id'
  belongs_to :customer, class_name: 'Company', foreign_key: 'customer_id'
  has_many :order_items
  has_many :comments
  belongs_to :year_month
  belongs_to :store
  belongs_to :order_type
  belongs_to :user
  scope :valid_orders, -> { where("orders.delete_flag is null or orders.delete_flag = 0") }
  scope :not_return_orders, -> { where("orders.return_flag = 0 or orders.return_flag is null") }
  def sum_money
    self.order_items.sum('money').round(2)
  end

  def previous previous_type
    if previous_type.blank?
      orders = Order.valid_orders.where(customer_id: self.customer_id, store_id: self.store_id, supplier_id: self.supplier_id).where("reach_order_date < ?", self.reach_order_date)
      orders = orders.order(:customer_id).order(:store_id).order(order_type_id: :desc)
      orders.where(reach_order_date: orders.maximum('reach_order_date')).first
    else
      previous_order = Order.valid_orders.where(customer_id: self.customer_id, store_id: self.store_id, supplier_id: self.supplier_id, order_type_id: previous_type.id, reach_order_date: self.reach_order_date).first
      return self.previous( previous_type.previous ) if previous_order.blank?
      previous_order
    end
  end

  def next next_type
    if next_type.blank?
      orders = Order.valid_orders.where(customer_id: self.customer_id, store_id: self.store_id, supplier_id: self.supplier_id).where("reach_order_date > ?", self.reach_order_date)
      orders = orders.order(:customer_id).order(:store_id).order(order_type_id: :asc)
      orders.where(reach_order_date: orders.minimum('reach_order_date')).first
    else
      next_order = Order.valid_orders.where(customer_id: self.customer_id, store_id: self.store_id, supplier_id: self.supplier_id, order_type_id: next_type.id, reach_order_date: self.reach_order_date).first
      return self.next( next_type.next ) if next_order.blank?
      next_order
    end
  end

  def self.export_order_total_for_specified_days start_date, end_date, customer_id, supplier_id, store_id
    order_type_num = OrderType.where(customer_id: customer_id, supplier_id: supplier_id).count
    customer = Company.find(customer_id)
    # supplier = Company.find(supplier_id)
    store = Store.find(store_id)
    Spreadsheet.client_encoding = 'UTF-8'
    book = Spreadsheet::Workbook.new
    in_center = Spreadsheet::Format.new horizontal_align: :center, vertical_align: :center, border: :thin
    in_left = Spreadsheet::Format.new horizontal_align: :left, border: :thin
    sheet1 = book.create_worksheet name: '明细'
    sheet1.merge_cells(0,0,0,order_type_num+1)
    sheet1.merge_cells(1,2,1,order_type_num+1)
    sheet1.row(0)[0] = "#{start_date.to_date.to_s(:db)}至#{end_date.to_date.to_s(:db)}#{customer.simple_name}#{store.name}单据明细"
    sheet1.row(0).height = 40
    # big_font = Spreadsheet::Font.new size: 20
    for i in 0..order_type_num+1 do
      sheet1.row(0).set_format(i, in_center)
    end
    sheet1.row(1)[0] = '日期'
    sheet1.row(1).set_format(0, in_center)
    sheet1.row(1)[1] = '每日小计'
    sheet1.row(1).set_format(1, in_center)
    sheet1.row(1)[2] = '详细'
    for j in 2..order_type_num+1 do
      sheet1.row(1).set_format(j, in_center)
    end

    current_row = 2
    all_total_money = 0
    for reach_date in start_date..end_date do
      for x in 0..order_type_num+1
        sheet1.row(current_row)[x] = ''
        sheet1.row(current_row+1)[x] = ''
      end
      sheet1.merge_cells( current_row,0,current_row+1,0)
      sheet1.row(current_row)[0] = reach_date.to_s
      day_total_money = 0
      orders = Order.valid_orders.where(customer_id: customer_id, store_id: store_id, supplier_id: supplier_id, reach_order_date: reach_date).order(:order_type_id)

      orders.each_with_index do |order, index|
        sheet1.row(current_row)[index+2] = order.order_type.name
        sum_money = order.sum_money
        sheet1.row(current_row+1)[index+2] = sum_money
        day_total_money += sum_money
      end
      all_total_money += day_total_money
      sheet1.merge_cells(current_row,1,current_row+1,1)
      sheet1.row(current_row)[1] = day_total_money
      sheet1.row(current_row).set_format(0,in_center)
      sheet1.row(current_row).set_format(1,in_center)
      sheet1.row(current_row+1).set_format(0,in_center)
      sheet1.row(current_row+1).set_format(1,in_center)
      for m in 2..order_type_num+1 do
        sheet1.row(current_row).set_format(m, in_left)
        sheet1.row(current_row+1).set_format(m, in_left)
      end
      current_row += 2
    end
    for n in 0..order_type_num+1
      sheet1.row(3).set_format(n, in_left)
    end
    for y in 0..order_type_num+1
      sheet1.row(current_row)[y] = ''
      sheet1.row(current_row).set_format(y, in_center)
    end
    sheet1.row(current_row)[0] = '总金额'
    sheet1.row(current_row)[1] = all_total_money
    file_path = "#{start_date.to_date.to_s(:db)}至#{end_date.to_date.to_s(:db)}#{customer.simple_name}#{store.name}单据明细.xls"
    book.write file_path
    file_path
  end

  def self.export_order_total_for_specified_month start_date, end_date, supplier_id
    Spreadsheet.client_encoding = 'UTF-8'
    book = Spreadsheet::Workbook.new
    in_center = Spreadsheet::Format.new horizontal_align: :center, vertical_align: :center, border: :thin
    in_left = Spreadsheet::Format.new horizontal_align: :left, border: :thin
    sheet1 = book.create_worksheet name: '明细'
    sheet1.merge_cells(1,0,2,0)
    sheet1.row(1).set_format(0,in_center)
    sheet1.row(2).set_format(0,in_center)
    sheet1.row(1).set_format(1,in_center)
    sheet1.row(2).set_format(1,in_center)
    sheet1.row(1)[0] = '日期'
    sheet1.row(1)[1] = '单位'
    sheet1.row(2)[1] = '门店'
    current_row = 3
    for reach_date in start_date..end_date do
      sheet1.row(current_row)[1] = ''
      sheet1.merge_cells(current_row,0,current_row,1)
      sheet1.row(current_row).set_format(0,in_left)
      sheet1.row(current_row).set_format(1,in_left)
      sheet1.row(current_row)[0] = reach_date.to_s
      current_row += 1
    end
    sheet1.merge_cells(current_row,0,current_row,1)
    sheet1.row(current_row).set_format(0,in_left)
    sheet1.row(current_row).set_format(1,in_left)
    sheet1.row(current_row)[0] = '门店小计'
    current_col = 2
    sum_money_of_all = 0
    # num = 1
    Company.find(supplier_id).customers.each do |customer|
      customer.stores.each do |store|
        sheet1.row(1).set_format(current_col,in_left)
        sheet1.row(1)[current_col] = customer.simple_name
        sheet1.row(2).set_format(current_col,in_left)
        sheet1.row(2)[current_col] = store.name
        current_row = 3
        sum_money_of_one_month = 0
        for reach_date in start_date..end_date do
          orders = Order.valid_orders.where(customer_id: customer.id, store_id: store.id, supplier_id: supplier_id, reach_order_date: reach_date)
          sum_money_of_one_day = 0
          orders.each do |order|
            sum_money_of_one_day += order.sum_money
          end
          # puts "***********************#{num}#{sum_money_of_one_day}*****************************"
          # num += 1
          sheet1.row(current_row).set_format(current_col,in_left)
          sheet1.row(current_row)[current_col] = sum_money_of_one_day == 0 ? '' : sum_money_of_one_day
          sum_money_of_one_month += sum_money_of_one_day
          current_row += 1
        end
        sheet1.row(current_row).set_format(current_col,in_left)
        sheet1.row(current_row)[current_col] = sum_money_of_one_month == 0 ? '' : sum_money_of_one_month
        sum_money_of_all += sum_money_of_one_month
        current_col += 1
      end
    end
    sheet1.merge_cells(0,0,0,current_col-1)
    0.upto current_col-1 do |x|
      sheet1.row(0).set_format(x, in_center)
    end
    sheet1.row(0)[0] = "#{Company.find(supplier_id).simple_name}从#{start_date}至#{end_date}账目明细"
    sheet1.merge_cells(current_row+1,0,current_row+1,current_col-1)
    0.upto current_col-1 do |x|
      sheet1.row(current_row+1).set_format(x, in_center)
    end
    sheet1.row(current_row+1)[0] = "#{start_date}至#{end_date}汇总:#{sum_money_of_all.round(2)}"
    file_path = "#{start_date.to_date.to_s(:db)}至#{end_date.to_date.to_s(:db)}单据明细.xls"
    book.write file_path
    file_path
  end

  def deleted?
    self.delete_flag?
  end

  def self.common_query options

    BusinessException.raise "未指定供应商是谁！" if options[:supplier_id].blank?

    orders = Order.valid_orders.where("orders.supplier_id = ?", options[:supplier_id]) unless options[:supplier_id].blank?

    unless options[:start_date].blank?
      start_date = options[:start_date].to_date.change(hour:0,min:0,sec:0)
      orders = orders.where("orders.reach_order_date >= ?", start_date)
    end

    unless options[:end_date].blank?
      end_date = options[:end_date].to_date.change(hour:23,min:59,sec:59)
      orders = orders.where("orders.reach_order_date <= ?", end_date)
    end

    orders = orders.where("orders.customer_id = ?", options[:customer_id]) unless options[:customer_id].blank?

    orders = orders.where("orders.customer_id <> ?", options[:not_customer_id]) unless options[:not_customer_id].blank?

    orders = orders.where("orders.not_input_number >= ?", options[:allowed_number_not_input]) unless options[:allowed_number_not_input].blank?

    orders.order("orders.customer_id, orders.reach_order_date")
  end

  def calculate_not_input_number
    count = self.order_items.where(real_weight: 0).count
    self.update_attribute :not_input_number, count
  end

  def self.all_calculate_not_input_number
    Order.valid_orders.each {|order| order.calculate_not_input_number }
    "ok"
  end

  def return
    self.update_attribute :return_flag, true
  end
end
