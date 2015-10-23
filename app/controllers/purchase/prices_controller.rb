class Purchase::PricesController < BaseController
  before_filter :need_login
  def index
    @prices = current_user.company.all_prices
  end

  def search
    company = current_user.company
    @supplies = company.supplies
    @year_months = YearMonth.all
    if request.post?
      @supplier_id = params[:supplier_id]
      @year_month_id = params[:year_month_id]
      @product_name = params[:product_name]
      # @search_results = company.get_prices.where(supplier_id: params[:supplier_id], year_month_id: params[:year_month_id])
      @search_results = Price.customer_query_price company.id, @supplier_id, @product_name, @year_month_id
    else
      @supplier_id = @supplies.first.id
      @year_month_id = YearMonth.current_year_month.id
      @search_results = Price.customer_query_price company.id, @supplier_id, '', @year_month_id
    end
  end
end
