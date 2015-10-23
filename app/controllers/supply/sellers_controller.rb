class Supply::SellersController < BaseController
  before_filter :need_login

  def index
    @sellers = current_user.company.sellers.order(:sort_number)
  end

  def new
    @seller = Seller.new
  end

  def create
    begin
      Seller.create_seller seller_params, current_user.company.id
      flash[:notice] = '创建卖家成功。'
      redirect_to supply_sellers_path
    rescue Exception=>e
      flash[:alert] = dispose_exception e
      @seller = Seller.new seller_params
      render :new
    end
  end

  def update
    begin
      Seller.find(params[:id]).update_seller seller_params
      flash[:notice] = '修改卖家信息成功。'
      redirect_to supply_sellers_path
    rescue Exception=>e
      flash[:alert] = dispose_exception e
      @seller = Seller.find(params[:id])
      render :edit
    end
  end

  def edit
    begin
      @seller = Seller.find(params[:id])
    rescue Exception=>e
      flash[:alert] = dispose_exception e
      render :index
    end
  end

  def prepare_set_general_products
    show_set_general_products_params
  end

  def do_set_general_products
    begin
      Seller.set_general_products params[:general_product_ids], params[:seller_id]
      flash[:notice] = '关联通用产品成功。'
      show_set_general_products_params
      render :prepare_set_general_products
      # redirect_to supply_sellers_path
    rescue Exception=>e
      flash[:alert] = dispose_exception e
      show_set_general_products_params
      render :prepare_set_general_products
    end
  end

  def up
    seller = Seller.find_by_id(params[:id])
    if seller.blank? || seller.sort_number == 0
      redirect_to action: :index
      return
    end
    pre_seller = Seller.find_by_sort_number(seller.sort_number - 1)
    pre_seller.update_attribute :sort_number, seller.sort_number unless pre_seller.blank?
    seller.update_attribute :sort_number, seller.sort_number - 1
    redirect_to action: :index
  end

  def down
    seller = Seller.find_by_id(params[:id])
    if seller.blank?
      redirect_to action: :index
      return
    end
    next_seller = Seller.find_by_sort_number(seller.sort_number + 1)
    next_seller.update_attribute :sort_number, seller.sort_number unless next_seller.blank?
    seller.update_attribute :sort_number, seller.sort_number + 1
    redirect_to action: :index
  end

  private
    def seller_params
      params.permit(:name, :shop_name, :phone, :address, :sort_number)
    end

    def show_set_general_products_params
      @name = params[:name]
      @seller_id = params[:seller_id]
      @seller = Seller.find(@seller_id)
      @general_products = current_user.company.general_products.where("seller_id <> ?", @seller_id).where("name like ?", "%#{@name}%").paginate(page: params[:page], per_page: 10)
      @linked_general_products = Seller.find(@seller_id).general_products
      @selected_general_products = GeneralProduct.find(params[:general_product_ids].blank? ? [] : params[:general_product_ids])
    end

end