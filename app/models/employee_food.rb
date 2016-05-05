class EmployeeFood < ActiveRecord::Base
  belongs_to :company, foreign_key: :supplier_id
  belongs_to :product

  scope :is_valid, ->{where is_valid: true}

  validates_presence_of :product, message: '产品需要指定'
  validates_presence_of :company, message: '公司需要指定'

  validates_uniqueness_of :product_id, message: '该产品已经加入到员工餐了。', scope: [:supplier_id, :is_valid]

  # 创建
  def self.add product_id, supplier_id
    self.where(product_id: product_id, supplier_id: supplier_id)
    ef = self.new product_id: product_id, supplier_id: supplier_id, is_valid: true
    ef.save!
  end

  def delete_it
    self.destroy!
  end
end