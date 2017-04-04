class Company < ActiveRecord::Base
  has_many :users
  has_many :get_prices, foreign_key: 'customer_id', class_name: 'Price' #得到的价格
  has_many :supply_prices, foreign_key: 'supplier_id', class_name: 'Price' #由自己提供的价格

  # 包含曾经的客户
  has_many :relations, foreign_key: 'company_id', class_name: 'CustomersCompanies'
  has_many :customers, through: :relations, source: :purchaser #下家，即我的客户

  # 只包含现在的客户
  has_many :now_relations, -> { where("delete_flag is null or delete_flag = 0 ")}, foreign_key: 'company_id', class_name: 'CustomersCompanies'
  has_many :now_customers, through: :now_relations, source: :purchaser

  has_many :reverse_relations, foreign_key: 'customer_id', class_name: 'CustomersCompanies'
  has_many :supplies, through: :reverse_relations, source: :supplier #上家，即我的供应商

  has_many :now_reverse_relations, -> { where("delete_flag is null or delete_flag = 0 ")}, foreign_key: 'customer_id', class_name: 'CustomersCompanies'
  has_many :now_supplies, through: :now_reverse_relations, source: :supplier

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
  has_many :stocks, foreign_key: :supplier_id

  has_many :month_inventories, foreign_key: :supplier_id

  has_many :employee_foods, foreign_key: :supplier_id

  #由eric添加
  has_many :purchase_prices, foreign_key: :supplier_id


  validates_uniqueness_of :simple_name, message: '客户简称已经被占用，请填写其他简称！'
  validates_uniqueness_of :full_name, message: '客户全称已经被占用，请填写其他全称！'

  def valid_purchase_prices
    self.purchase_prices.available
  end

  def all_prices
    Price.where("prices.supplier_id = ? and prices.customer_id in ( ? )", self.id, self.customers.ids).where(is_used: true)
  end

  def all_orders
    self.customers.collect { |cus| cus.orders }.flatten!
  end

  def vip_type
    return 0 if self.vip_info.blank? || self.vip_info.expired?
    self.vip_info.vip_type
  end

  def customer_count
    self.now_customers.count
  end

  # 管理员创建客户
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

  # 超级管理员创建供应商
  #  :simple_name, :full_name, :phone, :address, :store_name, :email, :password, :user_name, :terminal_password, :storage_name
  def self.create_supplier options = {}
    self.transaction do
      # 创建公司
      company = Company.new simple_name: options[:simple_name],
                            full_name: options[:full_name],
                            phone: options[:phone],
                            address: options[:address]
      company.save!


      # 创建门店
      store_ops = {
          :company_id => company.id,
          :name => options[:store_name]
      }
      store = Store.create_store store_ops


      # 创建管理员
      admin = User.new email: options[:email],
                       password: options[:password]
      admin.save!
      # 设置管理员角色
      admin.set_admin
      # 设置公司
      admin.company = company
      # 设置门店
      admin.store = store
      # 设置用户名
      admin.user_name = options[:user_name]
      # 设置客户端密码
      admin.terminal_password = options[:terminal_password]
      admin.save!


      # 创建仓库
      storage_ops = {
          :store_id => store.id,
          :name => options[:storage_name]
      }
      Storage.create_storage storage_ops

      company
    end
  end

  def self.all_suppliers
    all_supplier_ids = []
    Company.all.each do |c|
      all_supplier_ids << c.id if c.customers.count >= 1
    end
    where("id in (?)", all_supplier_ids)
  end

end
