# == Schema Information
#
# Table name: other_orders
#
#  id          :integer          not null, primary key
#  supplier_id :integer
#  storage_id  :integer
#  io_at       :datetime
#  creator_id  :integer
#  category    :integer
#  deleted_at  :datetime
#  note        :text(65535)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class OtherOrder < ApplicationRecord

  acts_as_paranoid

  has_many :product_items, inverse_of: :other_order, dependent: :destroy

  belongs_to :supplier, class_name: 'Company'

  belongs_to :creator, class_name: 'User'

  belongs_to :storage

  belongs_to :check

  enum category: [:profit, :loss]

  accepts_nested_attributes_for :product_items, allow_destroy: true

  validates :supplier, :storage, :io_at, :creator_id, :category, presence: true

  validates_associated :check

  after_save :change_stock

  def change_stock
    product_items.each do |product_item|
      OrderDetail.create! supplier_id: self.supplier_id,
                      storage_id: self.storage_id,
                      order_id: self.id,
                      detail_type: "check_#{category}",
                      detail_date: self.io_at,
                      item_id: product_item.id,
                      product_id: product_item.general_product.products.first.id,
                      price: product_item.price,
                      plan_weight: product_item.quantity,
                      real_weight: product_item.quantity,
                      money: product_item.amount,
                      delete_flag: false,
                      true_spec: product_item.unit
    end

    self.update_columns total_amount: product_items.sum(:amount).round(2)
  end

  def self.query_by(options = {})
    scope = self.all

    if options[:start_date].present?
      scope = scope.where('io_at >= ?', options[:start_date].to_date.beginning_of_day)
    end

    if options[:end_date].present?
      scope = scope.where('io_at <= ?', options[:end_date].to_date.end_of_day)
    end

    if options[:category].present?
      scope = scope.where(category: options[:category])
    end

    scope
  end
end
