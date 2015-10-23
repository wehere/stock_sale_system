class PrintOrderNotice < ActiveRecord::Base
  belongs_to :supplier, class_name: 'Company', foreign_key: 'supplier_id'
  belongs_to :customer, class_name: 'Company', foreign_key: 'customer_id'
  validates_presence_of :supplier, message: "必须关联一个存在的客户。"
  validates_presence_of :customer, message: "必须关联一个存在的供应商。"

  scope :match_notices, ->(supplier_id, customer_id) { where supplier_id: supplier_id, customer_id: customer_id }


  def self.notices
    pluck(:notice)
  end


  def self.create_notice options
    notice = self.new customer_id: options[:customer_id], supplier_id: options[:supplier_id], notice: options[:notice]
    notice.save!
    notice.reload
    notice
  end


end
