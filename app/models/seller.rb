class Seller < ActiveRecord::Base
  has_many :general_products
  belongs_to :company, foreign_key: :supplier_id

  validates_presence_of :name, message: '卖家名字不能为空。'
  validates_presence_of :sort_number, message: "排序号不能为空。"
  validates_uniqueness_of :sort_number, message: "排序号不可以重复。"
  def self.create_seller params, supplier_id
    self.transaction do
      seller = self.new name: params[:name], shop_name: params[:shop_name], phone: params[:phone],
                   address: params[:address], sort_number: params[:sort_number], supplier_id: supplier_id
      seller.save!
      seller
    end
  end

  def update_seller params
    Seller.transaction do
      unless params[:name].blank?
        self.name = params[:name]
      end
      unless params[:shop_name].blank?
        self.shop_name = params[:shop_name]
      end
      unless params[:phone].blank?
        self.phone = params[:phone]
      end
      unless params[:address].blank?
        self.address = params[:address]
      end
      unless params[:supplier_id].blank?
        self.supplier_id = params[:supplier_id]
      end
      unless params[:sort_number].blank?
        self.sort_number = params[:sort_number]
      end
      self.save!
      self
    end
  end

  def self.set_general_products general_product_ids, seller_id
    puts '********'*10
    puts general_product_ids
    self.transaction do
      general_product_ids.to_a.each do |g_p_id|
        GeneralProduct.find(g_p_id).update_attribute :seller_id, seller_id
      end
    end
  end

end
