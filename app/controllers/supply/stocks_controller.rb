class Supply::StocksController < BaseController
  def index
    @stocks = current_user.company.stocks
    unless params[:product_name].blank?
      @stocks = @stocks.joins(:general_product)
      @stocks = @stocks.where("general_products.name like ?", "%#{params[:product_name]}%")
    end
  end
end