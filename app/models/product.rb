class Product < ActiveRecord::Base
  has_many :order_details
  belongs_to :general_product
  has_many :prices, -> { where is_used: true }
  belongs_to :supplier, foreign_key: :supplier_id, class_name: :Company
  validates_presence_of :simple_abc, :message => '中文缩写不可以为空！'
  validates_uniqueness_of :chinese_name, scope: [:supplier_id], message: "产品名称已经存在，请选用其他产品名称"
  has_one :purchase_price, -> { where is_used: true }
  has_many :purchase_order_items

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


end
