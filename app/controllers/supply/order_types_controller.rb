class Supply::OrderTypesController < BaseController
  before_filter :need_login

  def index
    @customers = current_user.company.customers
  end

  def create
    begin
      @customer = Company.find(params[:customer_id])
      OrderType.create! customer_id: params[:customer_id], supplier_id: current_user.company.id, name: params[:order_type_name]
    rescue Exception => e
      flash[:alert] = dispose_exception e
      redirect_to supply_order_types_path
    end
  end

  def destroy
    begin
      @deleted_id = params[:id]
      OrderType.find(params[:id]).destroy
    rescue Exception=>e
      flash[:alert] = dispose_exception e
      redirect_to supply_order_types_path
    end
  end

  def new
    @id = params[:id]
  end
end
