class Supply::StocksController < BaseController
  before_filter :need_login
  def index
    @title = '库存情况'
    @stocks = current_user.company.stocks
    @stocks = @stocks.query_by(params.permit(:product_name, :category))
    @total_amount = @stocks.joins(:general_product).sum('general_products.current_purchase_price * stocks.real_weight').round(2)
    @stocks = @stocks.order(updated_at: :desc).paginate(per_page: 10, page: params[:page])
  end
end
