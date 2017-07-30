# == Schema Information
#
# Table name: products
#
#  id                 :integer          not null, primary key
#  english_name       :string(255)
#  chinese_name       :string(255)
#  simple_abc         :string(255)
#  spec               :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#  supplier_id        :integer
#  general_product_id :integer
#  print_times        :integer          default(0)
#  describe           :string(255)
#  is_valid           :boolean          default(TRUE)
#  mark               :string(255)      default("未分类")
#  barcode            :string(255)
#  sale_ratio         :float(24)        default(0.0)
#

class Product < ActiveRecord::Base
  has_many :order_details
  belongs_to :general_product
  has_many :prices, -> { where is_used: true }
  belongs_to :supplier, foreign_key: :supplier_id, class_name: :Company
  validates_presence_of :simple_abc, :message => '中文缩写不可以为空！'
  validates_uniqueness_of :chinese_name, scope: [:supplier_id], message: "产品名称已经存在，请选用其他产品名称"
  has_one :purchase_price, -> { where is_used: true }
  has_many :purchase_order_items
  has_one :loss_price, -> { where is_used: true }
  has_many :loss_order_items
  has_one :employee_food, -> {where is_valid: true}

  scope :is_valid, ->{where(is_valid: true)}

  MIN_SPEC = %w(斤 块 个 瓶 把 包 桶 根 箱 盒 米 公斤 袋 罐 双 卷 听 条 套 台 张 支 只 本)
  SUB_SPEC = %w(斤 块 个 瓶 把 包 桶 根 箱 盒 米 公斤 袋 罐 双 卷 听 条 套 台 毫升 克 张 只 支 本)

  MARK =%w(未分类 水产品 肉类 菇类 面类 冻品 粮油 调料 蔬菜 水果 杂货)

  def strict_update options
    Product.transaction do
      b = self.chinese_name.match /([\S]*)-([\u4e00-\u9fa5a-zA-Z\d\s]*)-([\u4e00-\u9fa5a-zA-Z\d]*)\(([?\d]*)([\u4e00-\u9fa5a-zA-Z\d]*)\)/
      c_name = "#{options[:brand]}-#{b[2]}-#{b[3]}(#{options[:number]}#{b[5]})"
      abc = Pinyin.t(c_name) { |letters| letters[0].upcase }
      self.chinese_name = c_name
      self.simple_abc = abc.gsub(" ","")
      self.mark = options[:mark]
      self.save!
      g_p = self.general_product
      if g_p.products.count == 1
        g_p.name = c_name
        g_p.save!
      end
    end
  end

  def update_sale_ratio options
    if !options[:sale_ratio].blank? && options[:sale_ratio].to_f != 0.0
      self.sale_ratio = options[:sale_ratio]
      self.save!
    end
  end

  def self.update_sale_ratio_by_mark mark, sale_ratio, supplier_id
    BusinessException.raise '请选择分类' if mark.blank?
    BusinessException.raise '售出系数必须大于1且小于2' if sale_ratio.blank? || sale_ratio.to_f <= 1 || sale_ratio.to_f >= 2
    Product.where(is_valid: true, supplier_id: supplier_id, mark: mark).each do |product|
      if product.sale_ratio.blank? || product.sale_ratio == 0
        product.update_attributes sale_ratio: sale_ratio
      end
    end
  end

  def self.force_update_sale_ratio_by_mark mark, sale_ratio, supplier_id
    BusinessException.raise '请选择分类' if mark.blank?
    BusinessException.raise '售出系数必须大于1且小于2' if sale_ratio.blank? || sale_ratio.to_f <= 1 || sale_ratio.to_f >= 2
    Product.where(is_valid: true, supplier_id: supplier_id, mark: mark).each do |product|
      product.update_attributes sale_ratio: sale_ratio
    end
  end

  def soft_delete
    Product.transaction do

      #置该产品相关的出货价格无效
      self.prices.each do |price|
        price.is_used = 0
        price.save!
      end

      #置该产品相关的进货价格无效
      p = self.purchase_price
      if p.present?
        p.is_used = 0
        p.save!
      end

      #如果当前产品关联的通用产品只有一个，置该通用产品无效
      gps = general_product.products
      if gps.count <= 1
        general_product.is_valid = 0
        general_product.save!
      end

      #当前产品置为无效
      self.is_valid = 0
      self.save!

    end
  end

  def remove_disable
    Product.transaction do

      #当前产品置为有效
      self.is_valid = 1
      self.save!

      #如果当前产品关联的通用产品有效
      general_product.is_valid = 1
      general_product.save!

      #置该产品相关的进货价格有效
      p = if self.purchase_price.present?
            self.purchase_price
          else
            PurchasePrice.where(supplier_id: self.supplier_id, product_id: self.id).order(created_at: :desc).first
          end
      if p.present?
        p.is_used = 1
        p.save!
      end

      #置该产品相关出货价格有效
      current_year_month = YearMonth.current_year_month
      customers = self.supplier.now_customers

      customers.each do |customer|
        price = Price.where(customer_id: customer.id, product_id: self.id, supplier_id: self.supplier_id).order(created_at: :desc).first
        current_year_month_price = price.dup
        current_year_month_price.year_month_id = current_year_month.id
        current_year_month_price.is_used = 1
        current_year_month_price.save!
      end

    end
  end

  def self.export supplier_id, customer_id, year_month_id
    supplier = Company.find(supplier_id)
    customer = Company.find(customer_id)
    year_month = YearMonth.find(year_month_id)
    Spreadsheet.client_encoding = "UTF-8"
    book = Spreadsheet::Workbook.new
    sheet = book.create_worksheet name: '产品清单'
    format = Spreadsheet::Format.new border: :thin
    merge_format = Spreadsheet::Format.new align: :merge, horizontal_align: :center, border: :thin

    current_row = 0
    temp_mark = "nil"

    products = Product.where(supplier_id: supplier_id, is_valid: true).order(:mark)
    products.each do |product|
      unless temp_mark==product.mark
        sheet.row(current_row).push product.mark
        current_row += 1
        temp_mark = product.mark
      end
      price = Price.where(customer_id: customer_id, product_id: product.id, is_used: true, supplier_id: supplier_id, year_month_id: year_month_id).first
      true_spec = if price.blank?
                    product.spec
                  else
                    price.true_spec
                  end
      sheet.row(current_row).push product.chinese_name, true_spec
      current_row += 1
    end

    file_path = "#{Rails.root}/public/downloads/#{supplier_id}/#{supplier.simple_name}_#{customer.simple_name}_#{year_month.val}_#{Time.now.to_i}_货品清单.xls"
    Dir.mkdir Rails.root.join("public","downloads/#{supplier_id}/") unless Dir.exist? Rails.root.join("public","downloads/#{supplier_id}/")
    book.write file_path
    file_path

  end

  def self.import_products_from_xls supplier_id, file_io
    message = '导入产品开始于' + Time.now.to_s + '             '
    name = file_io.original_filename
    origin_name_with_path = Rails.root.join('public', name)
    File.open(origin_name_with_path, 'wb') do |file|
      file.write(file_io.read)
    end
    book = Spreadsheet.open origin_name_with_path
    sheet = book.worksheet 0
    self.transaction do
      sheet.each_with_index do |row, index|
        next if index==0
        simple_abc = row[0]
        product_name = row[1]
        spec = row[2]
        products = Product.where(chinese_name: product_name, supplier_id: supplier_id)

        if products.blank?
          product = Product.create!(simple_abc: simple_abc, chinese_name: product_name, spec: spec, supplier_id: supplier_id)
          seller = Seller.find_or_create_by name: '其他', supplier_id: supplier_id, delete_flag: 0
          general_product = GeneralProduct.find_or_create_by name: product_name, supplier_id: supplier_id
          product.general_product = general_product
          product.save!
          if general_product.seller_id.blank?
            general_product.seller_id = seller.id
            general_product.save!
          end
        else
          message += product_name + '已经存在！'
          next
        end
      end
    end
    message += '导入产品结束于' + Time.now.to_s + '             '
    File.delete origin_name_with_path
    message
  end

  def self.export_product_in_out start_date, end_date, supplier_id

    Spreadsheet.client_encoding = 'UTF-8'
    book = Spreadsheet::Workbook.new
    in_center = Spreadsheet::Format.new horizontal_align: :center, vertical_align: :center, border: :thin
    in_left = Spreadsheet::Format.new horizontal_align: :left, border: :thin
    sheet = book.create_worksheet name: '明细'
    sheet.merge_cells(0,0,0,4)
    sheet.row(0)[0] = "#{Company.find_by_id(supplier_id).simple_name} #{start_date}至#{end_date} 每个产品入库、出库汇总"
    current_row = 1

    order_details = OrderDetail.where("delete_flag is null or delete_flag = 0").where(supplier_id: supplier_id)
    order_details = order_details.where("detail_date>= ?", start_date.to_time.change(hour:0,min:0,sec:0)) unless start_date.blank?
    order_details = order_details.where("detail_date<=?", end_date.to_time.change(hour:23,min:59,sec:59)) unless end_date.blank?
    hash = {}
    GeneralProduct.is_valid.where(supplier_id: supplier_id).order(:vendor).each do |gp|
      hash[gp.products.first.mark] ||= []

      in_weight = 0.0
      out_weight = 0.0
      in_money = 0.0
      out_money = 0.0
      loss_weight = 0.0
      loss_money = 0.0
      gp.products.each do |product|
        # 入
        order_details.where(product_id: product.id).where(detail_type: 1).each do |od|
          ratio = PurchaseOrderItem.find_by_id(od.item_id).purchase_price.ratio
          in_weight += od.real_weight * ratio
          in_money += od.money
        end

        # 出
        order_details.where(product_id: product.id).where(detail_type: 2).each do |od|
          ratio = OrderItem.find_by_id(od.item_id).price.ratio
          out_weight += od.real_weight * ratio
          out_money += od.money
        end

        # 损
        order_details.where(product_id: product.id).where("detail_type = 3 or detail_type = 4").each do |od|
          ratio = LossOrderItem.find_by_id(od.item_id).loss_price.ratio
          loss_weight += od.real_weight * ratio
          loss_money += od.money
        end
      end
      average_in_price = in_weight == 0.0 ? 0.0 : in_money/(in_weight*1.0)
      average_out_price = out_weight == 0.0 ? 0.0 : out_money/(out_weight*1.0)
      problem = average_out_price <= average_in_price ? '有' : ''

      hash[gp.products.first.mark] << {
          'name' => gp.name,
          'in_weight' => in_weight.round(2).to_s,
          'in_money' => in_money.round(2).to_s,
          'average_in_price' => average_in_price.round(2).to_s,
          'out_weight' => out_weight.round(2).to_s,
          'out_money' => out_money.round(2).to_s,
          'average_out_price' => average_out_price.round(2).to_s,
          'problem' => problem.to_s,
          'mini_spec' => gp.mini_spec,
          'loss_weight' => loss_weight.round(2).to_s,
          'loss_money' => loss_money.round(2).to_s
      }
    end

    mark = nil
    hash.keys.each_with_index do |m, index|
      unless mark == m
        mark = m
        current_row += 2 if index!=0
        sheet.merge_cells(current_row,0,current_row,7)
        sheet.row(current_row).set_format(0, in_center)
        sheet.row(current_row).push "下面是#{mark}"
        current_row += 1
      end
      hash[m].each do |gp|

        sheet.merge_cells(current_row, 0, current_row+1, 0)
        sheet.row(current_row).set_format(0, in_center)
        sheet.row(current_row).push gp['name'], "入库数量/#{gp['mini_spec']}", '入库金额/元', '入库均价', "出库数量/#{gp['mini_spec']}", "出库金额/元", '出库均价', '是否有问题', "损耗数量/#{gp['mini_spec']}", '损耗金额/元'
        current_row += 1
        sheet.row(current_row).push gp[name], gp['in_weight'], gp['in_money'], gp['average_in_price'], gp['out_weight'], gp['out_money'], gp['average_out_price'], gp['problem'], gp['loss_weight'], gp['loss_money']
        current_row += 1
      end
    end

    file_path = "#{Rails.root}/public/downloads/#{supplier_id}/#{start_date.to_date.to_s}至#{end_date.to_date.to_s}_#{Time.now.to_i}_产品入库出库损耗汇总.xls"
    Dir.mkdir Rails.root.join("public","downloads/#{supplier_id}/") unless Dir.exist? Rails.root.join("public","downloads/#{supplier_id}/")
    book.write file_path
    file_path
  end

  def self.export_total_day_money_by_vendor start_date, end_date, supplier_id
    Spreadsheet.client_encoding = 'UTF-8'
    book = Spreadsheet::Workbook.new
    in_center = Spreadsheet::Format.new horizontal_align: :center, vertical_align: :center, border: :thin
    in_left = Spreadsheet::Format.new horizontal_align: :left, border: :thin
    sheet = book.create_worksheet name: '统计'
    # sheet.merge_cells(0,0,0,4)
    # sheet.row(0)[0] = "#{Company.find_by_id(supplier_id).simple_name} #{start_date}至#{end_date} 每个产品入库、出库汇总"

    order_details = OrderDetail.where("order_details.detail_type = 1 and (order_details.delete_flag is null or order_details.delete_flag = 0) and order_details.supplier_id = ?", supplier_id)
    order_details = order_details.where("order_details.detail_date>= ?", start_date.to_time.change(hour:0,min:0,sec:0)) unless start_date.blank?
    order_details = order_details.where("order_details.detail_date<=?", end_date.to_time.change(hour:23,min:59,sec:59)) unless end_date.blank?
    order_details = order_details.joins(product: :general_product)
    h = order_details.group("general_products.vendor").group("order_details.detail_date").sum("order_details.money")
    h.each do |a|
      a.first[1] = a.first[1].to_date.to_s

    end



    n_h = {}
    h.each do |a|
      n_h[a[0].to_s] = a[1]
    end

    row = 1
    date = start_date.to_date
    while date <= end_date.to_date
      sheet.row(row)[0] = date.to_s
      date += 1.day
      row += 1
    end
    last_row = row
    sheet.row(row)[0] = '小计'

    total_money = 0.0
    col = 1
    Company.find(supplier_id).vendors.split(',').each do |k|
        sum_money = 0.0
        row = 0
        sheet.row(row)[col] = k
        row += 1


        date = start_date.to_date
        while date <= end_date.to_date
          money = n_h[[k,date.to_s].to_s].to_f.round(2)
          sheet.row(row)[col] = money==0.0 ? '' : money
          sum_money += money
          date += 1.day
          row += 1
        end
        sheet.row(row)[col] = sum_money.round(2)
        col += 1

        total_money += sum_money
    end

    sheet.row(last_row)[col] = total_money.round(2)
    file_path = "#{Rails.root}/public/downloads/#{supplier_id}/#{start_date.to_date.to_s}至#{end_date.to_date.to_s}_#{Time.now.to_i}_按商贩统计采购总金额.xls"
    Dir.mkdir Rails.root.join("public","downloads/#{supplier_id}/") unless Dir.exist? Rails.root.join("public","downloads/#{supplier_id}/")
    book.write file_path
    file_path
  end

  def self.export_product_list_by_store supplier_id, store_id
    customer_id = Store.find(store_id).company_id
    Spreadsheet.client_encoding = 'UTF-8'
    book = Spreadsheet::Workbook.new
    in_center = Spreadsheet::Format.new horizontal_align: :center, vertical_align: :center, border: :thin
    in_left = Spreadsheet::Format.new horizontal_align: :left, border: :thin
    sheet = book.create_worksheet name: '盘点'

    # 查出所有分类

    order_items = OrderItem.joins(:order)
    order_items = order_items.where("orders.store_id = ? and orders.supplier_id = ? ", store_id, supplier_id)
    product_ids = order_items.pluck("order_items.product_id").uniq
    all_product = Product.where("id in (?)", product_ids).where(supplier_id: supplier_id).is_valid

    marks = all_product.pluck(:mark).uniq

    row_index = 1
    marks.each do |mark|
      sheet.row(row_index).push '品类',	'品名',	'数量',	'单价/元',	'金额/元', '', '品类',	'品名',	'数量',	'单价/元',	'金额/元'
      sheet.row(row_index).set_format(0, in_center)
      sheet.row(row_index).set_format(1, in_center)
      sheet.row(row_index).set_format(2, in_center)
      sheet.row(row_index).set_format(3, in_center)
      sheet.row(row_index).set_format(4, in_center)

      sheet.row(row_index).set_format(6, in_center)
      sheet.row(row_index).set_format(7, in_center)
      sheet.row(row_index).set_format(8, in_center)
      sheet.row(row_index).set_format(9, in_center)
      sheet.row(row_index).set_format(10, in_center)

      row_index += 1
      products = all_product.where(mark: mark)
      mark_start_row_index = row_index
      is_1 = true
      products.each_with_index do |product, index|
        price_data = Price.where(customer_id: customer_id, product_id: product.id).where("prices.price is not null").order(year_month_id: :desc, is_used: :desc, according_purchase_date: :desc).first
        price = if price_data.blank?
                  ''
                else
                  price_data.price
                end
        if index%2 == 0
          sheet.row(row_index)[1], sheet.row(row_index)[2], sheet.row(row_index)[3], sheet.row(row_index)[4] = product.chinese_name, '', price, ''
          sheet.row(row_index).set_format(1, in_center)
          sheet.row(row_index).set_format(2, in_center)
          sheet.row(row_index).set_format(3, in_center)
          sheet.row(row_index).set_format(4, in_center)
          is_1 = true
        else
          sheet.row(row_index)[7], sheet.row(row_index)[8], sheet.row(row_index)[9], sheet.row(row_index)[10] = product.chinese_name, '', price, ''
          sheet.row(row_index).set_format(7, in_center)
          sheet.row(row_index).set_format(8, in_center)
          sheet.row(row_index).set_format(9, in_center)
          sheet.row(row_index).set_format(10, in_center)
          row_index += 1
          is_1 = false
        end
      end
      mark_end_row_index = if is_1
                             row_index
                           else
                             row_index - 1
                           end
      row_index += 1 if is_1

      sheet.merge_cells(row_index, 0, row_index, 8)
      sheet.row(row_index)[0] = '合计'
      sheet.row(row_index).set_format(0, in_center)

      sheet.merge_cells(mark_start_row_index, 0, mark_end_row_index, 0)
      sheet.row(mark_start_row_index)[0] = mark
      sheet.row(row_index).set_format(0, in_center)

      sheet.merge_cells(mark_start_row_index, 6, mark_end_row_index, 6)
      sheet.row(mark_start_row_index)[6] = mark
      sheet.row(row_index).set_format(6, in_center)

      row_index += 2
    end
    file_path = "#{Rails.root}/public/downloads/#{supplier_id}/#{Store.find(store_id).name}_#{Time.now.to_i}_产品盘点表.xls"
    Dir.mkdir Rails.root.join("public","downloads/#{supplier_id}/") unless Dir.exist? Rails.root.join("public","downloads/#{supplier_id}/")
    book.write file_path
    file_path
  end

end
