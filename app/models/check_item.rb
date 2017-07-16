# == Schema Information
#
# Table name: check_items
#
#  id                 :integer          not null, primary key
#  check_id           :integer
#  general_product_id :integer
#  product_name       :string(255)
#  unit               :string(255)
#  storage_quantity   :float(24)
#  quantity           :float(24)
#  profit_or_loss     :float(24)
#  check_item_type    :integer
#  note               :string(255)
#  deleted_at         :datetime
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

class CheckItem < ApplicationRecord

  acts_as_paranoid

  belongs_to :check, counter_cache: true, inverse_of: :check_items

  belongs_to :general_product

  enum check_item_type: [:profit, :equal, :loss]

  validates :check, :general_product, :storage_quantity, :quantity, presence: true

  before_save :type_init

  def type_init
    return if quantity.blank?
    self.profit_or_loss = quantity - storage_quantity
    if profit_or_loss > 0.0
      self.check_item_type = :profit
    elsif profit_or_loss == 0.0
      self.check_item_type = :equal
    else
      self.check_item_type = :loss
    end
  end
end
