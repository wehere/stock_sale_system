class Purchase::EmployeeFoodsController < BaseController
  before_filter :need_login

  def index
    @no_nav = true
    @suppliers = current_user.company.now_supplies
    @reach_date = params[:reach_date]||Time.now.to_date+1.day
    @default_supplier = if params[:supplier_id].blank?
                          @suppliers.first
                        else
                          Company.find_by_id params[:supplier_id]
                        end
    @employee_foods = @default_supplier.employee_foods.is_valid
    @employee_foods = @employee_foods.joins(:product)
    @employee_foods = @employee_foods.order("products.mark")
  end

  def send_employee_food_order
    customer = current_user.company
    begin
      order_type = OrderType.match_types(params[:supplier_id], customer.id).where(name: '员工餐').first
      BusinessException.raise '没有员工餐这个单据类型' if order_type.blank?
      order_message = ''
      params[:data].values.select{|x|!x[1].blank?}.each do |data|
        order_message += "#{data[0]}#{data[1]}#{data[2]},"
      end
      BusinessException.raise '请填写订货信息' if order_message.blank?
      SendOrderMessage.create_ supplier_id: params[:supplier_id],
                               customer_id: customer.id,
                               store_id: current_user.store_id,
                               user_id: current_user.id,
                               main_message: order_message,
                               secondary_message: params[:memo],
                               reach_date: params[:reach_date],
                               order_type_id: order_type.id
      flash[:success] = '发送成功'
      redirect_to action: :index
    rescue Exception => e
      flash[:alert] = dispose_exception e
      @reach_date = params[:reach_date]
      @default_supplier = Company.find_by_id params[:supplier_id]
      render :index
    end
  end
end