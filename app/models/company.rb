class Company < ActiveRecord::Base
  has_many :users
  has_many :get_prices, foreign_key: 'customer_id', class_name: 'Price' #得到的价格
  has_many :supply_prices, foreign_key: 'supplier_id', class_name: 'Price' #由自己提供的价格
  has_many :relations, foreign_key: 'company_id', class_name: 'CustomersCompanies'
  has_many :customers, through: :relations, source: :purchaser #下家，即我的客户
  has_many :reverse_relations, foreign_key: 'customer_id', class_name: 'CustomersCompanies'
  has_many :supplies, through: :reverse_relations, source: :supplier #上家，即我的供应商
  has_many :stores
  has_many :get_order_types, foreign_key: 'customer_id', class_name: 'OrderType' #对于该公司我提供的单据类型
  has_many :supply_order_types, foreign_key: 'supplier_id', class_name: 'OrderType' #给我提供的单据类型
  has_many :out_orders, foreign_key: 'customer_id', class_name: 'Order'#向供应商发的订单
  has_many :out_order_items, through: :out_orders, class_name: 'OrderItem'
  has_many :in_orders, foreign_key: 'supplier_id', class_name: 'Order' #自己收到的所有订单
  has_many :in_order_items, through: :in_orders, class_name: 'OrderItem'
  has_many :products, foreign_key: :supplier_id
  has_one :vip_info, foreign_key: :company_id
  has_many :sellers, foreign_key: :supplier_id
  has_many :general_products, foreign_key: :supplier_id

  validates_uniqueness_of :simple_name, message: '客户简称已经被占用，请填写其他简称！'
  validates_uniqueness_of :full_name, message: '客户全称已经被占用，请填写其他全称！'
  def all_prices
    Price.where("customer_id in ( ? )", self.customers.ids).where(is_used: true)
  end

  def all_orders
    self.customers.collect { |cus| cus.orders }.flatten!
  end

  def vip_type
    return 0 if self.vip_info.blank? || self.vip_info.expired?
    self.vip_info.vip_type
  end

  def customer_count
    self.customers.count
  end

  def create_customer params
    Company.transaction do
      vip_type = self.vip_type
      if self.customer_count <= VipAuthority.where(vip_type: vip_type).first.customer_count
        puts params
        customer = Company.create! params
        customer.supplies << self
      else
        BusinessException.raise '客户数量已经达到上限！'
      end
    end
  end

end
