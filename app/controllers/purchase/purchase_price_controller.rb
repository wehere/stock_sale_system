class Purchase::PurchasePriceController < BaseController

  before_filter :need_login

  def index
    @prices = PurchasePrice.query_purchase_price is_used: true,
                                                 product_name: params[:product_name],
                                                 supplier_id: current_user.company.id,
                                                 per_page: 10,
                                                 page: params[:page]
  end


private
  def price_params
    params.permit([:year_month_id,:customer_id,:product_id,:price,:true_spec,:supplier_id])
  end
end
