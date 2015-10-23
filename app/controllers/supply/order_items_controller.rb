class Supply::OrderItemsController < BaseController
  before_filter :need_login

  def new
    begin
      show_params_of_order_item_form
    rescue Exception=> e
      flash[:alert] = dispose_exception e
      redirect_to new_supply_order_item_path
    end
  end

  def create
    begin
      puts params
      price = Price.find(params[:price_id])
      OrderItem.create_order_item order_item_param.merge(product_id: price.product.id)
      redirect_to edit_supply_order_path(params[:order_id])
    rescue Exception=> e
      flash[:alert] = dispose_exception e
      show_params_of_order_item_form
      render :new
    end
  end

  def prices_search
    begin
      show_params_of_order_item_form
      render :new
    rescue Exception=> e
      flash[:alert] = dispose_exception e
      redirect_to new_supply_order_item_path
    end
  end

  def edit
    @order_item = OrderItem.find(params[:id])
  end

  def update
    puts params
    @order_item = OrderItem.find(params[:id])
    @order_item.update_attribute :plan_weight, params[:order_item_modal_plan_weight]
    @order_item.update_attribute :real_weight, params[:order_item_modal_real_weight]
    @order_item.change_price params[:order_item_modal_price]
    @order_item.update_money
  end

  def search
    supplier_id = current_user.company.id
    @customers = current_user.company.customers
    if request.post?
      @product_name = params[:product_name]
      @start_date = params[:start_date]
      @end_date = params[:end_date]
      @customer_id = params[:customer_id]
      @order_items = OrderItem.query_order_items params[:product_name], params[:start_date], params[:end_date], params[:customer_id], supplier_id
    else
      @product_name = ''
      @start_date = Time.now.to_date - 30.days
      @end_date = Time.now.to_date
      @customer_id = nil #current_user.company.customers.first.id
      @order_items = nil
    end
  end

  def null_price
    supplier_id = current_user.company.id
    # @order_items = OrderItem.find_null_price supplier_id
    @order_items = OrderItem.common_query params.permit(:start_date, :end_date, :customer_id, :not_customer_id).merge(supplier_id: supplier_id)
    @order_items = @order_items.joins(:price) unless @order_items.joins_values.include? :price
    @order_items = @order_items.where("prices.price is null or prices.price = 0")
    @order_items = @order_items.paginate(page: params[:page], per_page: 10)
  end

  def change_delete_flag
    # begin
      OrderItem.find(params[:id]).change_delete_status
      render :text => "ok"
      # flash[:notice] = "作废成功。"
      # redirect_to null_price_supply_order_items_path
    # rescue Exception=>e
    #   flash[:alert] = dispose_exception e
    #   redirect_to null_price_supply_order_items_path
    # end
  end

  def prepare_classify
    @specified_date = params[:specified_date].blank? ? Time.now.to_date + 1 : params[:specified_date]
  end

  def do_classify
    # begin
      file_name = OrderItem.classify current_user.company.id, params[:specified_date]
      if File.exists? file_name
        io = File.open(file_name)
        io.binmode
        send_data io.read, filename: file_name, disposition: 'inline'
        io.close
        File.delete file_name
      else
        flash[:alert] = '文件不存在！'
        @specified_date = params[:specified_date].blank? ? Time.now.to_date + 1 : params[:specified_date]
        render :prepare_classify
      end
    # rescue Exception=> e
    #   flash[:alert] = dispose_exception e
    #   @specified_date = params[:specified_date].blank? ? Time.now.to_date + 1 : params[:specified_date]
    #   render :prepare_classify
    # end

    # @supplier_id = current_user.company.id
    # @customers = current_user.company.customers.order(:simple_name)
    # @year_months = YearMonth.all.order(:id)
    # @current_year_month_id = params[:year_month_id] || YearMonth.current_year_month.id
    # if request.post?
    #   begin
    #     file_name = Price.export_xls_of_prices @supplier_id, params[:id], params[:year_month_id]
    #     if File.exists? file_name
    #       io = File.open(file_name)
    #       io.binmode
    #       send_data io.read, filename: file_name, disposition: 'inline'
    #       io.close
    #       File.delete file_name
    #     else
    #       flash[:alert] = '文件不存在！'
    #       redirect_to export_xls_of_prices_supply_prices_path
    #     end
    #   rescue Exception => e
    #     flash[:alert] = dispose_exception e
    #     render :export_xls_of_prices
    #   end
    # end
  end

  private
    def show_params_of_order_item_form
      @product_name = params[:product_name]
      @order_id = params[:order_id]
      @price_id = params[:price_id]
      @plan_weight = params[:plan_weight]
      @real_weight = params[:real_weight]
      unless @order_id.blank?
        @order = Order.find(@order_id)
        year_month_id = YearMonth.specified_year_month(@order.reach_order_date).id
        @prices = Price.available.prices_in(year_month_id).where(customer_id: @order.customer_id, supplier_id: @order.supplier_id)
        @prices = @prices.joins(:product).where("products.chinese_name like ? ", "%#{@product_name}%") unless @product_name.blank?
        @prices = @prices.paginate(page: params[:page], per_page: 10)
      end
    end

    def order_item_param
      params.permit(:order_id, :price_id, :real_weight, :plan_weight)
    end
end