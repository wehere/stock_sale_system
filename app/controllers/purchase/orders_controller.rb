class Purchase::OrdersController < BaseController
  before_filter :need_login
  def index
    @recent_months = YearMonth.recent_months
    date_param = params[:query_date].blank? ? Time.now.to_date : params[:query_date].to_date
    @active_month = YearMonth.chinese_month_format date_param
    @orders = current_user.company.out_orders.valid_orders.where(reach_order_date: date_param.at_beginning_of_month..date_param.at_end_of_month)
    @orders = @orders.where(supplier_id: params[:supplier_id]) unless params[:supplier_id].blank?
    @orders = @orders.where(store_id: params[:store_id]) unless params[:store_id].blank?
    @orders = @orders.paginate(page: params[:page], per_page: 31)
    @orders = @orders.order(:reach_order_date)
  end

  def edit
    order = Order.find(params[:id])
    @reach_date = order.reach_order_date
    @order_items = order.order_items
    @sum_money = order.sum_money
  end

  def new
    @supplies = current_user.company.supplies
    @customer_id = current_user.company.id
  end

  def send_message
    OrderMessageMailer.order_message_email(params[:customer_id],params[:supplier_id],params[:content],params[:need_reach_date]).deliver
    flash[:notice] = '发信成功'
    redirect_to welcome_vis_static_pages_path
  end

  def show
    @order = Order.find(params[:id])
    @pre_order = @order.previous @order.order_type.previous
    @next_order = @order.next @order.order_type.next
    @order_items = @order.order_items
    @sum_money = @order.sum_money
  end

  def comment
    begin
      comment = Comment.create! order_id: params[:order_id], content: params[:content], user_id: current_user.id
      OrderMessageMailer.question_order_message(params[:content],comment.created_at,params[:order_id]).deliver
      redirect_to purchase_order_path(params[:order_id])
    rescue Exception => e
      flash[:alert] = dispose_exception e
      redirect_to purchase_order_path(params[:order_id])
    end
  end

  def dingyu_send_order

    if request.post?

    else
      @no_nav = true
      @store = Store.find_by_id(current_user.store_id)
      if @store.blank?
        flash[:alert] = '当前用户没有配置门店信息，不可以下单'
        redirect_to welcome_vis_static_pages_path
        return
      end
      @customer = current_user.company
      @suppliers = @customer.supplies
      if @suppliers.blank?
        flash[:alert] = '没有供应商信息'
        redirect_to welcome_vis_static_pages_path
        return
      end
      params[:supplier_id] = @suppliers.first.id if params[:supplier_id].blank?
      @supplier_id = params[:supplier_id]
      if !@suppliers.pluck(:id).include? params[:supplier_id].to_i
        flash[:alert] = '错误的供应商信息'
        redirect_to welcome_vis_static_pages_path
        return
      end
      @marks = Product.where(supplier_id: 31, is_valid:1).group(:mark).order("count(*) desc").count
      #{"干货"=>117, "蔬菜"=>53, "冻品"=>37, "调料"=>28, "肉类"=>18, "豆制品"=>10, "水产品"=>9, "菇类"=>5, "面类"=>4, "水果"=>4, "杂货"=>3, "未分类"=>1}
      @big_marks = []
      @small_marks = []
      @marks.each do |k, v|
        if @big_marks.size < 5
          @big_marks << k
        else
          @small_marks << k
        end
      end
      @products = Product.is_valid.where(supplier_id: params[:supplier_id]).order(print_times: :desc)
      @supplier_id = params[:supplier_id]
      @order_types = OrderType.match_types(@supplier_id, @customer.id)
    end
  end

  def get_spec_by_product_name
    params[:reach_date] = Time.now.to_date
    if params[:supplier_id].blank? || params[:product_name].blank?
      render text: "1|没有指定供应商或产品名"
      return
    end
    if params[:reach_date].blank?
      render text: "1|没有指定到货日期"
      return
    end
    customer_id = current_user.company.id
    product = Product.where(supplier_id: params[:supplier_id],
                            chinese_name: params[:product_name],
                            is_valid: true
    ).first
    year_month_id = YearMonth.find_or_create_by(val: YearMonth.chinese_month_format(params[:reach_date].to_date)).id
    price = Price.where(year_month_id:year_month_id,
                        customer_id:customer_id,
                        product_id:product.id,
                        is_used:true,
                        supplier_id:params[:supplier_id]
    ).first
    if price.blank?
      render text: "1|该产品没有对应的价格"
      return
    end
    render text: "0|#{price.true_spec}"
  end

  def query_product_by_abc
    @result_products = Product.where(supplier_id: params[:supplier_id],
                  is_valid: true
    ).where("simple_abc like ?", "%#{params[:abc]}%").order(print_times: :desc)
  end

  def send_message
    if params[:supplier_id].blank?
      render text: '1|没有指定供应商或产品名'
      return
    end
    # if params[:main_message].blank?
    #   render text: '1|还没有选择产品呢'
    #   return
    # end
    customer = current_user.company
    begin
    SendOrderMessage.create_ supplier_id: params[:supplier_id],
                             customer_id: customer.id,
                             store_id: current_user.store_id,
                             user_id: current_user.id,
                             main_message: params[:main_message],
                             secondary_message: params[:secondary_message],
                             reach_date: params[:reach_date],
                             order_type_id: params[:order_type_id]
    rescue Exception=>e
      render text: "1|#{dispose_exception(e)}"
      return
    end
    render text: '0|订单发送成功。'
  end

end
