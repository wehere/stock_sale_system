class Sp::CompaniesController < BaseController
  # layout 'super_admin'
  before_filter :need_login
  before_filter :need_super_admin

  def index

    @companies = if params[:all]=='1'
                   Company.all.paginate(page: params[:page],:per_page => 15)
                 else
                   Company.all_suppliers.paginate(page: params[:page],:per_page => 15)
                 end
  end

  def new
  	@company = Company.new
  end

  def create
    @company = Company.create_supplier company_params
    flash[:success] = "Company created!"
    redirect_to sp_companies_path
 end

 def show
  @company = Company.find(params[:id])
end

  def edit
    @company = Company.find(params[:id])
  end

  def update
    @company = Company.find(params[:id])
    if @company.update_attributes(company_params)
      flash[:success] = "更新成功!"
      redirect_to sp_company_path(params[:id])
    else
      render 'edit'
    end
  end

  def destroy
    # Company.find(params[:id]).destroy
    # flash[:success] = "删除成功."
    # redirect_to companies_url
  end


  private
    def company_params
      params.permit(:simple_name, :full_name, :phone, :address, :store_name, :email, :password, :user_name, :terminal_password, :storage_name)
    end

end