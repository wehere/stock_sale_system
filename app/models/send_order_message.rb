# == Schema Information
#
# Table name: send_order_messages
#
#  id                :integer          not null, primary key
#  supplier_id       :integer
#  customer_id       :integer
#  store_id          :integer
#  user_id           :integer
#  reach_date        :datetime
#  order_type_id     :integer
#  main_message      :text(65535)
#  secondary_message :text(65535)
#  is_valid          :boolean          default(TRUE)
#  is_dealt          :boolean          default(FALSE)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class SendOrderMessage < ActiveRecord::Base

  DEALT_STATUS ={
      false => '未处理',
      true => '处理'
  }

  belongs_to :supplier, foreign_key: :supplier_id, class_name: :Company
  belongs_to :customer, foreign_key: :customer_id, class_name: :Company
  belongs_to :store
  belongs_to :user
  belongs_to :order_type

  validates_presence_of :supplier, message: '供应商要指定'
  validates_presence_of :customer, message: '订货单位要指定'
  validates_presence_of :store, message: '门店要指定'
  validates_presence_of :user, message: '订货人要指定'
  validates_presence_of :order_type, message: '单据类型要指定'

  scope :is_valid, ->{ where is_valid: true }
  scope :not_valid, ->{ where is_valid: false }
  scope :is_dealt, ->{ where is_dealt: true }
  scope :not_dealt, ->{ where is_dealt: false }

  def self.create_ options
    m = self.new options
    m.save!
    # 发送邮件通知供应商
    SendOrderMessageJob.set(wait: 5.minutes).perform_later(m.id)
    m
  end

  def self.send_email id
    m = self.find_by_id(id)
    if m.is_valid
      OrderMessageMailer.send_to_supplier(m.id).deliver_now
    end
  end

end
