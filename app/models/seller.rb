class Seller < ActiveRecord::Base
  has_many :general_products, foreign_key: 'another_seller_id'
  belongs_to :company, foreign_key: :supplier_id
  has_many :purchase_orders

  scope :valid, -> {where("delete_flag is null or delete_flag = 0 ")}

  validates_presence_of :name, message: '供应商名字不能为空。'
  # validates_presence_of :sort_number, message: "排序号不能为空。"
  # validates_uniqueness_of :sort_number, message: "排序号不可以重复。", allow_blank: true
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
        GeneralProduct.find(g_p_id).update_attribute :another_seller_id, seller_id
      end
    end
  end

end
