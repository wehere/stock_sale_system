# == Schema Information
#
# Table name: product_items
#
#  id                 :integer          not null, primary key
#  supplier_id        :integer
#  other_order_id     :integer
#  product_id         :integer
#  general_product_id :integer
#  quantity           :float(24)
#  unit               :string(255)
#  price              :float(24)
#  amount             :float(24)
#  deleted_at         :datetime
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

class ProductItem < ApplicationRecord

  acts_as_paranoid

  belongs_to :other_order

  belongs_to :supplier, class_name: 'Company'

  belongs_to :general_product

  validates :supplier, :other_order, :general_product, :product_name, :quantity, :unit, :price, :amount, presence: true

  after_initialize do
    self.amount = (quantity.to_f * price.to_f).round(2)
  end

  after_commit :delete_order_detail_if_deleted, prepend: true

  def delete_order_detail_if_deleted
    if deleted?
      order_detail = OrderDetail.where(supplier_id: supplier_id, order_id: other_order_id, item_id: id, detail_type: "check_#{other_order.category}").first
      order_detail.update_attributes delete_flag: true
    end
  end
end
