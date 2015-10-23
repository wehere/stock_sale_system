require "spreadsheet"
class Price < ActiveRecord::Base
  belongs_to :year_month
  belongs_to :product
  belongs_to :supplier, class_name: 'Company', foreign_key: 'supplier_id'
  belongs_to :customer, class_name: 'Company', foreign_key: 'customer_id'
  has_many :price_change_historieses
  has_many :order_items
  scope :prices_in, ->(year_month_id) { where(year_month_id: year_month_id)}
  scope :available, -> { where(is_used: 1) }
  validate :validate, on: :create

  def validate
    errors.add(:product_id, "该产品:#{product_id}价格已经存在！#{year_month_id}:#{product_id}:#{customer_id}") if Price.where(product_id: product_id, customer_id: customer_id, supplier_id: supplier_id, year_month_id: year_month_id, is_used: true).count >= 1
  end

  def real_price
    self.price
  end

  def generate_next_month next_month_id
    return nil if Price.exists? year_month_id: next_month_id, customer_id: self.customer_id, product_id: self.product_id, supplier_id: self.supplier_id, is_used: true
    new_price = self.dup
    new_price.update_attributes! year_month_id: next_month_id
  end

  def self.generate_next_month_batch prices, next_month_id
    self.transaction do
      prices.order(:customer_id).each do |price|
        price.generate_next_month next_month_id
      end
    end
  end

  def self.import_prices_from_xls  supplier_id, customer_id, year_month_id, file_io
    message = '导入开始于' + Time.now.to_s + '\r'
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
        product_name = row[1]
        # product = Product.find_by_chinese_name(product_name)
        product = Product.where(chinese_name: product_name, supplier_id: supplier_id).first
        if product.blank?
          message += product_name + '不在产品列表中'
          next
        end

        found_prices = Price.where(supplier_id: supplier_id, customer_id: customer_id, year_month_id: year_month_id, product_id: product.id)
        unless found_prices.blank?
          message += product_name + '已经存在于价格表中'
          next
        end
        price = row[2]
        true_spec = row[3]
        Price.create!(price: price, true_spec: true_spec, is_used: true,
                              customer_id: customer_id, supplier_id: supplier_id,
                              year_month_id: year_month_id, product_id: product.id )
      end
    end
    File.delete origin_name_with_path
    message
  end

  def self.export_xls_of_prices supplier_id, customer_id, year_month_id
    prices = Price.where(supplier_id: supplier_id, customer_id: customer_id, year_month_id: year_month_id).available
    BusinessException.raise '该月份该单位没有对应的报价表！' if prices.blank?
    Spreadsheet.client_encoding = "UTF-8"
    book = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet name: '报价表'
    format = Spreadsheet::Format.new border: :thin
    merge_format = Spreadsheet::Format.new align: :merge, horizontal_align: :center
    sheet1.merge_cells(0,0,0,4)
    sheet1.row(0).set_format(0,merge_format)
    sheet1.row(0)[0] = '上海胜兴食品报价表'
    %w{产品ID 产品名称 产品规格 产品价格 备注}.each_with_index do |title,index|
      sheet1.row(1).set_format(index,format)
      sheet1.row(1).push title
    end
    prices.each_with_index do |price,index|
      5.times { |i| sheet1.row(index+2).set_format(i,format) }
      sheet1.row(index+2).push price.product.id, price.product.chinese_name.to_s, price.true_spec, price.price, ''
    end
    file_path = YearMonth.find(year_month_id).val + Company.find(supplier_id).simple_name +
        '_to_' + Company.find(customer_id).simple_name+ '的报价表' + Time.now.to_s(:db)+ ".xls"
    book.write file_path
    file_path
  end

  def self.customer_query_price customer_id, supplier_id, product_name, year_month_id
    sql = <<-EOF
      select * from prices left join products
      on prices.product_id = products.id
      where prices.customer_id = #{customer_id}
      and prices.supplier_id = #{supplier_id}
      and prices.is_used = 1
      and products.chinese_name like '%#{product_name}%'
      and prices.year_month_id = #{year_month_id}
    EOF
    Price.find_by_sql(sql)
  end
end
