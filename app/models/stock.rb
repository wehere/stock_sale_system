# == Schema Information
#
# Table name: stocks
#
#  id                  :integer          not null, primary key
#  general_product_id  :integer
#  storage_id          :integer
#  real_weight         :float(24)
#  min_weight          :float(24)
#  last_purchase_price :float(24)
#  created_at          :datetime
#  updated_at          :datetime
#  supplier_id         :integer
#

class Stock < ActiveRecord::Base

  acts_as_paranoid

  belongs_to :supplier, foreign_key: :supplier_id, class_name: :Company
  belongs_to :general_product
  belongs_to :storage

  def purchase_price
    PurchasePrice.where(supplier_id: self.supplier_id, is_used: 1, product_id: self.general_product.products.first.id).first rescue nil
  end

  def self.query_by(options = {})
    scope = self.all

    scope = scope.joins(:general_product)

    if options[:product_name].present?
      scope = scope.where('general_products.name like ?', "%#{options[:product_name]}%")
    end

    if options[:category].present?
      scope = scope.joins(general_product: :products)
      scope = scope.where(products: {mark: options[:category]})
    end

    scope
  end
end
