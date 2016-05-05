class Supply::EmployeeFoodsController < BaseController
  before_filter :need_login
  def index
    @products = if params[:key].blank?
                  Product.where("1=2")
                else
                  current_user.company.products.where("chinese_name like ? or simple_abc like ? ", "%#{params[:key]}%","%#{params[:key]}%")
                end
    @employee_foods = current_user.company.employee_foods.is_valid
  end

  def add_it
    need_admin
    begin
      EmployeeFood.add params[:product_id], current_user.company.id
      flash[:success] = 'OK'
      redirect_to action: :index
    rescue Exception => e
      flash[:alert] = dispose_exception e
      redirect_to action: :index
    end
  end

  def delete_it
    need_admin
    begin
      ef = EmployeeFood.find_by_id(params[:id])
      BusinessException.raise '失败，没有指定员工餐产品' if ef.blank?
      ef.delete_it
      flash[:success] = 'OK'
      redirect_to action: :index
    rescue Exception => e
      flash[:alert] = dispose_exception e
      redirect_to action: :index
    end
  end
end