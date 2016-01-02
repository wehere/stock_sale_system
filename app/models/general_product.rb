class GeneralProduct < ActiveRecord::Base
  belongs_to :seller, foreign_key: "another_seller_id"
  belongs_to :company, foreign_key: :supplier_id
  has_many :products
  has_one :stock
  scope :is_valid, ->{where(is_valid: true)}
  attr_accessor :skip_mini_spec_check
  validates_presence_of :name, message: '名称不可以为空。'
  validates_uniqueness_of :name, message: '该通用产品已经存在。', scope: [:supplier_id]
  validate :mini_spec_check

  after_create do |g_p|
    GeneralProduct.delay.check_repeated g_p.supplier_id
  end

  after_save do |g_p|
    GeneralProduct.delay.check_repeated g_p.supplier_id
  end

  def mini_spec_check
    if mini_spec_changed? && persisted? && !skip_mini_spec_check
      used = false
      self.products.each do |product|
        p_p = product.purchase_price
        if !p_p.blank? && !p_p.ratio.blank?
          used = true
          break
        end
        product.prices.each do |price|
          if !price.ratio.blank?
            used = true
            break
          end
        end
      end
      errors.add(:general_product, "本通用产品已经关联一些价格，并且换算比率已经有了，本通用产品不可以再改动了") if used
    end
  end

  def self.create_general_product params, supplier_id
    self.transaction do
      g_p = self.where(name: params[:name], supplier_id: supplier_id)
      if g_p.blank?
        another_seller = Seller.find_or_create_by name: "其他东西", delete_flag: 1, supplier_id: supplier_id
        general_product = self.new name: params[:name], seller_id: params[:seller_id], another_seller_id: another_seller.id, supplier_id: supplier_id
        general_product.save!
        general_product
      else
        g_p
      end
    end
  end

  def update_general_product params
    GeneralProduct.transaction do
      self.update_attributes! name: params[:name],
                              another_seller_id: params[:seller_id],
                              mini_spec: params[:mini_spec],
                              skip_mini_spec_check: self.mini_spec.blank?
      self
    end
  end

  def self.check_repeated supplier_id
    names = GeneralProduct.where(supplier_id: supplier_id, is_valid: true).pluck(:name)
    names = names.collect{|x|x.match(/-[\u4e00-\u9fa5a-zA-Z\d]+-/).to_s[1..-2]}
    h = {}
    names.each do |name|
      if h[name].blank?
        h[name] = 1
      else
        h[name] += 1
      end
    end
    h = h.select{|k,v| v>=2 }
    if h.count >= 1
      # send email to admin
      AdminMailer.product_repeated(h.keys.join(",")).deliver
    end
  end
end
__END__
1、在系统内先建好卖货人，大概也就10条数据
2、参照chen历史笔记，整理出常用的那些品项，写入excel表格（包括名字、卖货人id）
3、导入到数据库表general_products
4、系统遍历一遍产品表，做到部分产品自动关联到general_products
5、每天打完单据后，点击［生成拿货单］，产生一个excel文件，打印，ok
6、测试一星期、补全没有关联的产品

生成拿货单前，要检查是否有产品没有关联到通用产品上去。