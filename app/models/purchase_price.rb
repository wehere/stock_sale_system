require "spreadsheet"
class PurchasePrice < ActiveRecord::Base
  belongs_to :supplier, class_name: 'Company', foreign_key: 'supplier_id'
  belongs_to :seller
  belongs_to :product

  scope :available, -> { where(is_used: true) }

  validates_uniqueness_of :product_id, scope: :supplier_id, conditions: -> {where(is_used: true)}

  # 查询入库价格（从批发市场购买的价格）
  # 1.根据产品名称进行查询  product_name
  # 2.根据是否有效进行查询   is_used
  # 3.根据供应商（supplier）进行查询  :supplier_id
  # 4.分页查询  :page   :per_page
  def self.query_purchase_price options
    price = PurchasePrice.where "1=1"
    price = unless options[:is_used].nil?
              price.where is_used: options[:is_used]
            end

    price = unless options[:supplier_id].nil?
              price.where supplier_id: options[:supplier_id]
            end

    unless options[:product_name].nil?
      products = Product.where ['chinese_name like ? or simple_abc like ?', "%#{options[:product_name]}%", "%#{options[:product_name]}%"]
      price = price.where product_id: products.collect(&:id)
    end

    price = price.paginate(per_page: options[:per_page]||10, page: options[:page]||1)

    price
  end

  def update_purchase_price options
    PurchasePrice.transaction do

      old_attributes = self.attributes
      old_attributes.delete("id")

      pps = PurchasePrice.where supplier_id: self.supplier_id, product_id: self.product_id, is_used: true
      pps.each do |p|
        p.is_used = false
        p.save!
      end
      pur_p = PurchasePrice.new old_attributes
      pur_p.is_used = true
      pur_p.save!


      pur_p.update! options
      pur_p
    end
  end


end
