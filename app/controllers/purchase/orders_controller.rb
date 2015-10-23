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
end
