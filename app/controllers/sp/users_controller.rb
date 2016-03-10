class Sp::UsersController < BaseController
  before_filter :need_super_admin
  layout 'super_admin'
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
        redirect_to action: :index
        return
      end
      @companies = Company.all
    end
  end
end