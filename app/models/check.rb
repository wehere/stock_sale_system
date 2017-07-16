# == Schema Information
#
# Table name: checks
#
#  id                :integer          not null, primary key
#  supplier_id       :integer
#  storage_id        :integer
#  category          :string(255)
#  creator_id        :integer
#  check_items_count :integer
#  status            :integer
#  checked_at        :date
#  deleted_at        :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class Check < ApplicationRecord

  acts_as_paranoid

  has_many :check_items, dependent: :destroy, inverse_of: :check

  belongs_to :storage

  belongs_to :supplier, class_name: 'Company'

  belongs_to :creator, class_name: 'User'

  has_one :profit_other_order, -> { where category: :profit }, class_name: 'OtherOrder'

  has_one :loss_other_order, -> { where category: :loss }, class_name: 'OtherOrder'

  accepts_nested_attributes_for :check_items, allow_destroy: true

  enum status: [:draft, :submitted]

  validate :uniq_category_other_order

  def uniq_category_other_order
    profit_orders = OtherOrder.where(category: :profit, check_id: self.id)
    if profit_orders.size > 0
      errors.add(:id, '该盘点单已经生成了盘盈单')
    end
    loss_orders = OtherOrder.where(category: :loss, check_id: self.id)
    if loss_orders.size > 0
      errors.add(:id, '该盘点单已经生成了盘亏单')
    end
  end

  def can_generate_profit?
    submitted? && profit_other_order.blank? && has_profit?
  end

  def can_generate_loss?
    submitted? && loss_other_order.blank? && has_loss?
  end

  def has_profit?
    check_items.profit.any?
  end

  def has_loss?
    check_items.loss.any?
  end

end
