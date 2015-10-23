class Supply::CustomersController < BaseController
  before_filter :need_login
  def index
    @supplier = current_user.company
    @customers = @supplier.customers
  end

  def new
    @customer = Company.new
  end

  def create
    begin
      customer = current_user.company.create_customer params[:company].permit(:simple_name, :full_name, :phone, :address)
      flash[:notice] = "创建成功！"
      redirect_to supply_customers_path
    rescue Exception=> e
      flash[:alert] = dispose_exception e
      @customer = Company.new params[:company].permit(:simple_name, :full_name, :phone, :address)
      render :new
    end
  end

  def add_store
    if request.post?
      begin
        Store.create_store params.permit :company_id, :name
        flash[:notice] = "创建成功。"
        redirect_to action: :index
      rescue Exception=>e
        flash[:alert] = dispose_exception e
        @customer = Company.find_by_id(params[:company_id])
        render :add_store
      end
    else
      @customer = Company.find_by_id(params[:customer_id])
    end
  end

  def add_order_type
    if request.post?
      begin
        OrderType.create_order_type params.permit :customer_id, :supplier_id, :name
        flash[:notice] = "创建成功。"
        redirect_to action: :index
      rescue Exception=>e
        flash[:alert] = dispose_exception e
        @customer = Company.find_by_id(params[:customer_id])
        @supplier = current_user.company
        render :add_order_type
      end
    else
      @customer = Company.find_by_id(params[:customer_id])
      @supplier = current_user.company
    end
  end

  def add_notice
    if request.post?
      begin
        PrintOrderNotice.create_notice params.permit :customer_id, :supplier_id, :notice
        flash[:notice] = "创建成功。"
        redirect_to action: :index
      rescue Exception=>e
        flash[:alert] = dispose_exception e
        @customer = Company.find_by_id(params[:customer_id])
        @supplier = current_user.company
        render :add_order_type
      end
    else
      @customer = Company.find_by_id(params[:customer_id])
      @supplier = current_user.company
    end
  end
end