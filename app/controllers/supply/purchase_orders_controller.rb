class Supply::PurchaseOrdersController < BaseController
  before_filter :need_login

  def index
    supplier_id = current_user.company.id
    params[:start_date] ||= Time.now.to_date - 10.days
    params[:end_date] ||= Time.now.to_date
    start_date = params[:start_date].to_time.change(hour:0, min:0, sec:0)
    end_date = params[:end_date].to_time.change(hour:23, min:59, sec:59)
    @purchase_orders = PurchaseOrder.where("purchase_orders.supplier_id = ? and (purchase_orders.delete_flag is null or purchase_orders.delete_flag = 0) and purchase_orders.purchase_date between ? and ?", supplier_id, start_date, end_date).order(:purchase_date)
    unless params[:product_name].blank?
      @purchase_orders = @purchase_orders.joins(purchase_order_items: :product).where("products.chinese_name like ?", "%#{params[:product_name]}%")
    end
    @purchase_orders = @purchase_orders.paginate(page: params[:page]||1, per_page: params[:per_page]||10)
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
end