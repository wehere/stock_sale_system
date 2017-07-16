# == Schema Information
#
# Table name: loss_prices
#
#  id          :integer          not null, primary key
#  supplier_id :integer
#  seller_id   :integer
#  is_used     :boolean
#  true_spec   :string(255)
#  price       :float(24)
#  product_id  :integer
#  ratio       :float(24)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class LossPrice < ActiveRecord::Base
  belongs_to :product
  has_many :loss_order_items
  scope :is_used, -> { where is_used: 1 }

  def update_price new_price
    LossPrice.transaction do
      new_price = new_price.to_f
      BusinessException.raise "#{self.product.chinese_name}的价格必须是数字，且不可以为0" if new_price == 0.0
      new_loss_price = self.dup
      self.is_used = 0
      self.save!
      new_loss_price.price = new_price
      new_loss_price.save!
      new_loss_price
    end
  end
end
