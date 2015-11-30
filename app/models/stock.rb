class Stock < ActiveRecord::Base
  belongs_to :supplier, foreign_key: :supplier_id, class_name: :Company
  belongs_to :general_product
  belongs_to :storage

  def purchase_price
    PurchasePrice.where(supplier_id: self.supplier_id, is_used: 1, product_id: self.general_product.products.first.id).first rescue nil
  end
end