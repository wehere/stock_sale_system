class Supply::GeneralProductsController < BaseController
  before_filter :need_login

  def index
    @name = params[:name]
    @general_products = current_user.company.general_products.is_valid.order(id: :desc).where("name like ?", "%#{params[:name]}%").paginate(page: params[:page], per_page: 10)
    @vendors = current_user.company.vendors.split(",")
  end

  def vendor
    g_p = GeneralProduct.find_by_id(params[:general_product_id])
    g_p.update_attribute :vendor, params[:vendor]
    render text: 'ok'
  end

  def complex
    if params[:password]=="cxp"
      @general_products = current_user.company.general_products
      @general_products = @general_products.where("name like ?", "%#{params[:name]}%") unless params[:name].blank?
      @general_products = @general_products.where(pass: true) if params[:pass_status] == '1'
      @general_products = @general_products.where("pass is null or pass = 0") if params[:pass_status] == "0"
      @general_products = @general_products.paginate(per_page: params[:per_page]||5, page: params[:page]||1)
    end

  end

  def change_pass_status
    g_p = GeneralProduct.find(params[:g_p_id])
    g_p.update_attribute :pass, !g_p.pass
    render text: g_p.pass ? '1' : '0'
  end

  def common_complex
    @general_products = current_user.company.general_products
    @general_products = @general_products.where("name like ?", "%#{params[:name]}%") unless params[:name].blank?
    arr = []
    @general_products.each do |g_p|
      if g_p.mini_spec.blank?
        arr<<g_p
      else
        need_make_up = false
        products = g_p.products
        products.each do |product|
          next if need_make_up
          prices = Price.where(product_id: product.id)
          prices.each do |price|
            need_make_up = true if price.true_spec.blank? || price.ratio.blank?
          end
        end
        arr << g_p if need_make_up
      end
    end
    @general_products = GeneralProduct.where(id: arr.collect{|x|x.id})
    @general_products = @general_products.paginate(per_page: params[:per_page]||5, page: params[:page]||1)
  end

  def save_g_p_mini_spec
    if params[:mini_spec].blank?
      render text: 'error'
    else
      GeneralProduct.find(params[:g_p_id]).update_attribute :mini_spec, params[:mini_spec]
      render text: params[:mini_spec]
    end
  end

  def save_price_true_spec
    if params[:true_spec].blank?
      render text: 'error'
    else
      Price.find(params[:price_id]).update_attribute :true_spec, params[:true_spec]
      render text: params[:true_spec]
    end
  end

  def save_price_ratio
    if params[:ratio].blank?
      render text: 'error'
    else
      Price.find(params[:price_id]).update_attribute :ratio, params[:ratio]
      render text: params[:ratio]
    end
  end

  def save_purchase_price_true_spec
    if params[:true_spec].blank?
      render text: 'error'
    else
      PurchasePrice.find(params[:purchase_price_id]).update_attribute :true_spec, params[:true_spec]
      render text: params[:true_spec]
    end
  end

  def save_purchase_price_ratio
    if params[:ratio].blank?
      render text: 'error'
    else
      PurchasePrice.find(params[:purchase_price_id]).update_attribute :ratio, params[:ratio]
      render text: params[:ratio]
    end
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
      @general_product = GeneralProduct.new name: params[:name], another_seller_id: params[:seller_id], supplier_id: current_user.company.id
      @sellers = current_user.company.sellers
      @seller = @general_product.seller
      render :new
    end
  end

  def edit
    @title = '编辑通用产品'
    begin
      supplier_id = current_user.company.id
      @general_product = GeneralProduct.where(id: params[:id], supplier_id: supplier_id, is_valid: 1).first
      BusinessException.raise '找不到该通用产品' if @general_product.blank?
      @sellers = current_user.company.sellers
      @seller = @general_product.seller
    rescue Exception=>e
      flash[:alert] = dispose_exception e
      redirect_to '/supply/products'
    end
  end

  def update
    params.permit!
    supplier_id = current_user.company.id
    begin
      g_p = GeneralProduct.where(id: params[:id], supplier_id: supplier_id, is_valid: 1).first
      BusinessException.raise '找不到该通用产品' if g_p.blank?
      g_p.update_general_product params.permit(:barcode, :location, :memo, :seller_id)
      flash[:notice] = '产品修改成功。'
      redirect_to '/supply/products'
    rescue Exception=>e
      flash[:alert] = dispose_exception e
      @general_product = GeneralProduct.find(params[:id])
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

  def check_repeated
    GeneralProduct.check_repeated current_user.company.id
    redirect_to '/supply/general_products/'
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
