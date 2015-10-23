class Product < ActiveRecord::Base
  belongs_to :general_product
  has_many :prices
  belongs_to :supplier, foreign_key: :supplier_id, class_name: :Company
  validates_presence_of :simple_abc, :message => '中文缩写不可以为空！'
  validate :validate

  def validate
    errors.add(:product_id, "产品名称已经存在，请选用其他产品名称！") if Product.where(supplier_id: supplier_id, chinese_name: chinese_name).count >= 1
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
          Product.create!(simple_abc: simple_abc, chinese_name: product_name, spec: spec, supplier_id: supplier_id)
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
