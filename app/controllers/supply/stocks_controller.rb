class Supply::StocksController < BaseController
  before_filter :need_login
  def index
    @title = '库存情况'
    @stocks = current_user.company.stocks
    unless params[:product_name].blank?
      @stocks = @stocks.joins(:general_product)
      @stocks = @stocks.where('general_products.name like ?', "%#{params[:product_name]}%")
    end
  end
end
