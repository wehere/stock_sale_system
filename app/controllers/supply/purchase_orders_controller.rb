class Supply::PurchaseOrdersController < BaseController
  before_filter :need_login

  def index
    supplier_id = current_user.company.id
    @purchase_orders = PurchaseOrder.where("purchase_orders.supplier_id = ? and (purchase_orders.delete_flag is null or purchase_orders.delete_flag = 0)", supplier_id)
    # params[:start_date] ||= Time.now.to_date - 10.days
    # params[:end_date] ||= Time.now.to_date
    unless params[:start_date].blank?
      start_date = params[:start_date].to_time.change(hour:0, min:0, sec:0)
      @purchase_orders = @purchase_orders.where("purchase_orders.purchase_date >= ?", start_date)
    end
    unless params[:end_date].blank?
      end_date = params[:end_date].to_time.change(hour:23, min:59, sec:59)
      @purchase_orders = @purchase_orders.where("purchase_orders.purchase_date <= ?", end_date)
    end
    unless params[:product_name].blank?
      @purchase_orders = @purchase_orders.joins(purchase_order_items: :product).where("products.chinese_name like ?", "%#{params[:product_name]}%")
    end
    unless params[:memo].blank?
      @purchase_orders = @purchase_orders.where("purchase_orders.memo like ? ", "%#{params[:memo]}%")
    end
    @purchase_orders = @purchase_orders.order(purchase_date: :desc).paginate(page: params[:page]||1, per_page: params[:per_page]||10)
  end

  def edit
    @purchase_order = PurchaseOrder.find_by_id(params[:id])
    @purchase_order_items = PurchaseOrderItem.where(purchase_order_id: params[:id])
  end

  def change_order_item
    begin
      purchase_order_item = PurchaseOrderItem.find_by_id(params[:purchase_order_item_id])
      purchase_order_item.change_order_item params[:real_weight], params[:price], current_user
      render text: 'ok'
    rescue Exception=>e
      render text: 'error'
    end
  end

  def destroy
    purchase_order = PurchaseOrder.find(params[:id])
    success_message = "进货单据ID为#{purchase_order.id},日期为#{purchase_order.purchase_date.strftime("%Y年%m月%d日")},被删除成功。"
    purchase_order.delete_self current_user
    flash[:notice] = success_message
    redirect_to action: :index
  end
end