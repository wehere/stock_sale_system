class GeneralProduct < ActiveRecord::Base
  belongs_to :seller
  belongs_to :company, foreign_key: :supplier_id
  has_many :products

  validates_presence_of :name, message: '名称不可以为空。'
  validates_uniqueness_of :name, message: '该通用产品已经存在。'

  def self.create_general_product params, supplier_id
    self.transaction do
      general_product = self.new name: params[:name], seller_id: params[:seller_id], supplier_id: supplier_id
      general_product.save!
      general_product
    end
  end

  def update_general_product params
    GeneralProduct.transaction do
      self.update_attribute :name, params[:name] unless params[:name].blank?
      self.update_attribute :seller_id, params[:seller_id] unless params[:seller_id].blank?
      self
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