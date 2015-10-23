class Supply::GeneralProductsController < BaseController
  before_filter :need_login

  def index
    @name = params[:name]
    @general_products = current_user.company.general_products.where("name like ?", "%#{params[:name]}%").paginate(page: params[:page], per_page: 10)
  end

  def new
    @general_product = GeneralProduct.new
    @sellers = current_user.company.sellers
    @seller = @sellers.first
  end

  def create
    params.permit!
    begin
      GeneralProduct.create_general_product params, current_user.company.id
      flash[:notice] = '产品创建成功。'
      if params[:commit] == "保存&继续创建"
        redirect_to new_supply_general_product_path
      else
        redirect_to supply_general_products_path
      end
    rescue Exception=>e
      flash[:alert] = dispose_exception e
      @general_product = GeneralProduct.new name: params[:name], seller_id: params[:seller_id], supplier_id: current_user.company.id
      @sellers = current_user.company.sellers
      @seller = @general_product.seller
      render :new
    end
  end

  def edit
    begin
      @general_product = GeneralProduct.find(params[:id])
      @sellers = current_user.company.sellers
      @seller = @general_product.seller
    rescue Exception=>e
      flash[:alert] = dispose_exception e
      redirect_to supply_general_products_path
    end
  end

  def update
    params.permit!
    begin
      GeneralProduct.find(params[:id]).update_general_product params
      flash[:notice] = '产品修改成功。'
      redirect_to supply_general_products_path
    rescue Exception=>e
      flash[:alert] = dispose_exception e
      @general_product = GeneralProduct.new params
      @sellers = current_user.company.sellers
      @seller = @general_product.seller
      render :edit
    end
  end

  def prepare_link_to_seller
    show_link_to_seller_params
  end

  def do_link_to_seller
    begin
      GeneralProduct.find(params[:general_product_id]).update_attribute :seller_id, params[:seller_id]
      flash[:notice] = '关联卖货人成功。'
      redirect_to supply_general_products_path
    rescue Exception=>e
      flash[:alert] = dispose_exception e
      show_link_to_seller_params
      render :prepare_link_to_seller
    end
  end

  def destroy

  end

  private
    def show_link_to_seller_params
      @name = params[:name]
      @general_product_id = params[:general_product_id]
      @seller_id = params[:seller_id]
      @seller = GeneralProduct.find(params[:general_product_id]).seller rescue nil
      @sellers = @name.blank? ? current_user.company.sellers : Seller.where("name like ?", "%#{@name}%")
      @sellers = @sellers.paginate(page: params[:page], per_page: 10)
    end

end
