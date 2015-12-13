class Supply::PurchaseOrdersController < BaseController
  before_filter :need_login

  def index
    @purchase_orders = PurchaseOrder.where("delete_flag is null or delete_flag = 0")
  end

end