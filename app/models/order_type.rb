class OrderType < ActiveRecord::Base
  has_many :orders
  belongs_to :supplier, class_name: 'Company', foreign_key: 'supplier_id'
  belongs_to :customer, class_name: 'Company', foreign_key: 'customer_id'
  validates_presence_of :name, message: "单据类型不可以为空。"
  validates_presence_of :supplier, message: "必须关联一个存在的客户。"
  validates_presence_of :customer, message: "必须关联一个存在的供应商。"
  validates_uniqueness_of :name, scope: [:customer_id, :supplier_id], message: "单据类型不可以重复。"

  scope :match_types, ->(supplier_id, customer_id) { where supplier_id: supplier_id, customer_id: customer_id }


  def self.names
    pluck(:name)
  end


  def self.create_order_type options
    order_type = self.new customer_id: options[:customer_id], supplier_id: options[:supplier_id], name: options[:name]
    order_type.save!
    order_type.reload
    order_type
  end

  def previous
    all_order_types = self.customer.get_order_types.order(:id)
    count = all_order_types.count
    return nil if count == 1 or count == 0
    pos = -1
    0.upto count-1 do |i|
      if all_order_types[i].name == self.name
        pos = i
        break
      end
    end
    return nil if pos == -1
    return nil if pos == 0
    return all_order_types[pos - 1]
  end

  def next
    all_order_types = self.customer.get_order_types.order(:id)
    count = all_order_types.count
    return nil if count == 1 or count == 0
    pos = -1
    0.upto count-1 do |i|
      if all_order_types[i].name == self.name
        pos = i
        break
      end
    end
    return nil if pos == -1
    return nil if pos == count - 1
    return all_order_types[pos + 1]
  end
end
