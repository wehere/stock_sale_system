class Sp::UsersController < BaseController
  before_filter :need_super_admin
  # layout 'super_admin'
  def index
    @users =User.all
  end

  def link_company
    if request.post?
      begin
        User.link_company params.permit(:user_id, :company_id)
        flash[:success] = '关联成功'
        redirect_to action: :index
      rescue Exception=>e
        flash[:alert] = dispose_exception e
        redirect_to action: :index
      end
    else
      @user = User.find_by_id(params[:id])
      if @user.blank?
        flash[:alert] = '找不到用户'
        redirect_to action: :index
        return
      end
      @companies = Company.all
    end
  end

  def edit
    @user = User.find_by_id(params[:id])
    if @user.blank?
      flash[:alert] = '找不到用户'
      redirect_to action: :index
      return
    end
  end

  def update
    user = User.find_by_id(params[:id])
    if user.blank?
      flash[:alert] = '找不到用户'
      redirect_to action: :index
      return
    end
    begin
      user.update_terminal_info params.permit(:user_name, :terminal_password)
      flash[:success] = '修改成功'
      redirect_to action: :index
    rescue Exception=>e
      flash[:alert] = dispose_exception e
      redirect_to "/sp/users/#{user.id}/edit"
    end
  end
end