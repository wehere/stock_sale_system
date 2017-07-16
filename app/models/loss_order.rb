# == Schema Information
#
# Table name: loss_orders
#
#  id          :integer          not null, primary key
#  storage_id  :integer
#  loss_date   :datetime
#  user_id     :integer
#  delete_flag :boolean          default(FALSE)
#  supplier_id :integer
#  seller_id   :integer
#  loss_type   :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  memo        :string(1000)
#

class LossOrder < ActiveRecord::Base
  LOSS_TYPE = {
      3 => '仓库损耗',
      4 => '销售损耗'
  }
  belongs_to :seller
  has_many :loss_order_items

  def sum_money
    LossOrder.joins(:loss_order_items).where(id: self.id).sum("loss_order_items.money").round(2)
  end

  def delete_self current_user
    LossOrder.transaction do
      self.loss_order_items.each do |poi|
        poi.delete_self current_user, false
      end
      self.update_attributes delete_flag: 1
    end
  end
end
