class Sp::CompaniesController < ApplicationController
  def index
    @companies = Company.order(params[:simple_name]).paginate(page: params[:page],:per_page => 5)
  end

  def new
  	@company = Company.new
  end

  def create
   @company = Company.new(company_params)
   if @company.save
     flash[:success] = "Company created!"
     redirect_to sp_companies_path
   else
     render 'sp/companies/new'
   end
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
    Company.find(params[:id]).destroy
    flash[:success] = "删除成功."
    redirect_to companies_url
  end


  private
    def company_params
      params.require(:company).permit(:simple_name, :full_name, :phone,:address)
    end

end