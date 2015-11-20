class Supply::ProductsController < BaseController
  before_filter :need_login
  def index
    begin
      @key_value = params[:key]
      unless params[:key].blank?
        @products = current_user.company.products.where("id = ? or chinese_name like ? or simple_abc like ? ", params[:key],"%#{params[:key]}%","%#{params[:key]}%")
      else
        @products = current_user.company.products
      end
      @products = @products.order(id: :desc).paginate(page: params[:page]||1, per_page: params[:per_page]||10)
    rescue Exception=>e
      flash[:alert] = '查询失败，' + dispose_exception(e)
    end
  end

  def create_one
    product = Product.new product_params
    begin
      Product.transaction do
        product.supplier = current_user.company
        product.save!
        options = {}
        options[:name] = product.chinese_name
        seller = Seller.find_or_create_by name: "其他", delete_flag: 0, supplier_id: product.supplier_id
        options[:seller_id] = seller.id
        general_product = GeneralProduct.create_general_product options, product.supplier_id
        product.general_product = general_product
        product.save!
        PurchasePrice.create_purchase_price supplier_id: product.supplier_id,
                                            seller_id: seller.id,
                                            is_used: true,
                                            true_spec: '斤',
                                            price: nil,
                                            product_id: product.id,
                                            ratio: 500
      end
      flash[:notice] = "创建成功"
      redirect_to new_supply_product_path
    rescue Exception => e
      flash[:alert] = dispose_exception e
      @product = product
      render :new
    end
  end

  def new
    @product = Product.new
    @product.supplier = current_user.company
  end

  def edit
    begin
      @product = current_user.company.products.find(params[:id])
    rescue Exception=>e
      flash[:alert] = dispose_exception e
      redirect_to supply_products_path
    end
  end

  def update
    begin
      current_user.company.products.find(params[:id]).update_attributes product_params
      flash[:notice] = "修改成功！"
      redirect_to supply_products_path
    rescue Exception=>e
      flash[:alert] = dispose_exception e
      redirect_to supply_product_path(params[:id]), method: :patch
    end
  end

  def import_products_from_xls
    if request.post?
      supplier_id = current_user.company.id
      file_io = params[:products_xls]
      flash[:notice] = Product.import_products_from_xls supplier_id, file_io
      redirect_to import_products_from_xls_supply_products_path
    end
  end

  def prepare_link_to_general_product
    show_link_to_general_product_params
  end

  def do_link_to_general_product
    begin
      Product.find(params[:product_id]).update_attribute :general_product_id, params[:general_product_id]
      flash[:notice] = '关联成功。'
      redirect_to supply_products_path
    rescue Exception=>e
      flash[:alert] = dispose_exception e
      show_link_to_general_product_params
      render :prepare_link_to_general_product
    end
  end

  private

    def product_params
      params.require(:product).permit([:english_name,:chinese_name,:spec,:simple_abc])
    end

    def show_link_to_general_product_params
      @product_id = params[:product_id]
      @product = Product.find(params[:product_id])
      @general_product = @product.general_product
      @name = params[:name]
      @general_products = @name.blank? ? current_user.company.general_products : GeneralProduct.where("name like ? ", "%#{@name}%")
      @general_products = @general_products.paginate(page: params[:page], per_page: 10)
      @general_product_id = params[:general_product_id]
    end
end