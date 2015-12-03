class Product < ActiveRecord::Base
  belongs_to :general_product
  has_many :prices, -> { where is_used: true }
  belongs_to :supplier, foreign_key: :supplier_id, class_name: :Company
  validates_presence_of :simple_abc, :message => '中文缩写不可以为空！'
  validates_uniqueness_of :chinese_name, scope: [:supplier_id], message: "产品名称已经存在，请选用其他产品名称"
  has_one :purchase_price, -> { where is_used: true }


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
