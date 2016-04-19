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
      @products = @products.is_valid.order(id: :desc).paginate(page: params[:page]||1, per_page: params[:per_page]||10)
      @marks = current_user.company.marks.split(",")
    rescue Exception=>e
      flash[:alert] = '查询失败，' + dispose_exception(e)
    end
  end

  def show
    @product = current_user.company.products.is_valid.find(params[:id])
    @general_product = @product.general_product
  end

  def change_sale_ratio
    need_admin
    if request.post?
      product = current_user.company.products.is_valid.find(params[:id])
      product.update_sale_ratio sale_ratio: params[:sale_ratio]
      flash[:success] = '更新成功'
      redirect_to "/supply/products/#{params[:id]}"
    else
      @product = current_user.company.products.is_valid.find(params[:id])
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
                                            true_spec: '',
                                            price: nil,
                                            product_id: product.id,
                                            ratio: 0
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
    need_warehouseman
    # @product = Product.new
    # @product.supplier = current_user.company
    redirect_to action: :strict_new if current_user.warehouseman?
  end

  def strict_new
    need_warehouseman
    @MIN_SPEC = JSON.parse(current_user.company.min_specs).keys rescue []
    pp @MIN_SPEC.class
    @SUB_SPEC = []
    @marks = current_user.company.marks.split(",") rescue []
    @vendors = current_user.company.vendors.split(",") rescue []
  end

  def change_sub_spec
    @sub_spec = JSON.parse(current_user.company.min_specs)[params[:min_spec]] rescue []
    pp @sub_spec
  end

  def strict_create
    need_warehouseman
    begin
      pp "*"*100
      pp params
      pp "*"*100

      Product.transaction do
        params[:brand].gsub!("？", "?")
        params[:number].gsub!("？", "?")
        BusinessException.raise '［品牌名］不可以空着' if params[:brand].blank?
        BusinessException.raise '［品名］不可以空着' if params[:name].blank?
        BusinessException.raise '［品名］不可以包含括号' if params[:name].match /[()（）<>《》]/
        BusinessException.raise '请选择［进货单位］' if params[:purchase_spec].blank?
        BusinessException.raise '［相对出货最小单位的比率］不可以空着' if params[:purchase_ratio].blank?
        BusinessException.raise '［相对出货最小单位的比率］只可以是数字' if !params[:purchase_ratio].match /^[0-9]+$/
        if params[:number] != "?"
          BusinessException.raise '［大小］只可以是数字' if !params[:number].match /^[0-9]+$/
        end
        BusinessException.raise '请选择［单位］' if params[:min_spec].blank?
        BusinessException.raise '请选择［大小的单位］' if params[:sub_spec].blank?
        supplier_id = current_user.company.id
        if params[:check] == "1"
          products = Product.where("chinese_name like ? and is_valid = 1 and supplier_id = ? ", "%#{params[:name]}%", supplier_id)
          unless products.blank?
            render text: "1|#{products.pluck(:chinese_name).join("^")}"
            return
          end
        end

        c_name = "#{params[:brand]}-#{params[:name]}-#{params[:min_spec]}(#{params[:number]}#{params[:sub_spec]})"
        abc = Pinyin.t(c_name) { |letters| letters[0].upcase }
        g_p = GeneralProduct.where(name: c_name, is_valid: true, supplier_id: supplier_id).first
        seller = Seller.find_or_create_by name: "其他", delete_flag: 0, supplier_id: supplier_id
        if g_p.blank?
          g_p = GeneralProduct.new name: c_name,
                                   seller_id: seller.id,
                                   supplier_id: supplier_id,
                                   vendor: params[:vendor],
                                   mini_spec: params[:min_spec]
          g_p.save!
        end

        product = Product.new chinese_name: c_name,
                    simple_abc: abc.gsub(" ",""),
                    spec: params[:min_spec],
                    supplier_id: supplier_id,
                    general_product_id: g_p.id,
                    is_valid: 1,
                    mark: params[:mark]
        product.save!
        # 产生进货价格
        purchase_price = PurchasePrice.new supplier_id: supplier_id,
                          seller_id: seller.id,
                          is_used: 1,
                          true_spec: params[:purchase_spec],
                          price: 0,
                          product_id: product.id,
                          ratio: params[:purchase_ratio],
                          print_times: 1
        purchase_price.save!
        # 产生损耗价格
        loss_price = LossPrice.new supplier_id: supplier_id,
                                   seller_id: seller.id,
                                   is_used: 1,
                                   true_spec: params[:purchase_spec],
                                   price: 0,
                                   product_id: product.id,
                                   ratio: params[:purchase_ratio]
        loss_price.save!
        # 产生出货价格
        current_year_month = YearMonth.current_year_month
        next_year_month = YearMonth.next_year_month
        customers = current_user.company.now_customers
        customers.each do |customer|
          current_year_month_price = Price.new year_month_id: current_year_month.id,
                            customer_id: customer.id,
                            product_id: product.id,
                            is_used: 1,
                            true_spec: params[:min_spec],
                            supplier_id: supplier_id,
                            print_times: 1,
                            ratio: 1
          current_year_month_price.save!
          next_year_month_price = Price.new year_month_id: next_year_month.id,
                            customer_id: customer.id,
                            product_id: product.id,
                            is_used: 1,
                            true_spec: params[:min_spec],
                            supplier_id: supplier_id,
                            print_times: 1,
                            ratio: 1
          next_year_month_price.save!
        end
        render text: "0|#{c_name}"
      end
    rescue Exception=>e
      render text: "2|" + dispose_exception(e)
    end
  end

  def strict_edit
    need_warehouseman
    supplier_id = current_user.company.id
    @product = Product.where(id: params[:id], supplier_id: supplier_id, is_valid: 1).first
    if @product.blank?
      flash[:alert] = '没有查到该产品'
      redirect_to '/vis/static_pages/welcome/'
      return
    end
    @MIN_SPEC = JSON.parse(current_user.company.min_specs).keys rescue []
    @SUB_SPEC = []
    @marks = current_user.company.marks.split(",") rescue []
  end

  def strict_update
    need_warehouseman
    supplier_id = current_user.company.id
    product = Product.where(id: params[:id], supplier_id: supplier_id, is_valid: 1).first
    begin
      params[:brand].gsub!("？", "?")
      params[:number].gsub!("？", "?")
      BusinessException.raise '［品牌名］不可以空着' if params[:brand].blank?
      if params[:number] != "?"
        BusinessException.raise '［大小］只可以是数字' if !params[:number].match /^[0-9]+$/
      end
      pp params
      product.strict_update params.permit(:brand, :number, :mark)
      flash[:notice] = '修改成功'
      redirect_to "/supply/products/strict_edit?id=#{product.id}"
    rescue Exception=>e
      flash[:alert] = dispose_exception e
      redirect_to "/supply/products/strict_edit?id=#{product.id}"
    end
  end

  def edit
    need_warehouseman
    begin
      @product = current_user.company.products.find(params[:id])
    rescue Exception=>e
      flash[:alert] = dispose_exception e
      redirect_to supply_products_path
    end
  end

  def update
    need_warehouseman
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

  def mark
    product = Product.find_by_id(params[:product_id])
    product.update_attribute :mark, params[:mark]
    render text: 'ok'
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

  def prepare_export_products
    @customers = current_user.company.now_customers
    @year_months = []
    @year_months << YearMonth.pre_year_month
    @year_months << YearMonth.current_year_month
    @year_months << YearMonth.next_year_month
  end

  def export_products
    file_name = Product.delay.export current_user.company.id, params[:customer_id], params[:year_month_id]
    # if File.exists? file_name
    #   io = File.open(file_name)
    #   io.binmode
    #   send_data io.read, filename: file_name, disposition: 'inline'
    #   io.close
    #   File.delete file_name
    # else
    #   flash[:alert] = '文件不存在！'
    #   @customers = current_user.company.customers
    #   @year_months = YearMonth.order(id: :desc).limit(4)
    #   render :prepare_export_products
    # end
    flash[:notice] = "正在下载，下载完毕后，您可以在下载页看到您需要的文件"
    redirect_to action: :prepare_export_products
  end

  def detail
    unless params[:key].blank?
      products = current_user.company.products.is_valid
      @products = products.where(barcode: params[:key])
      @products = products.where("chinese_name like ?", "%#{params[:key]}%") if @products.blank?
    end
  end

  def soft_delete
    unless current_user.admin?
      flash[:alert] = '此操作权限只限于管理员'
      redirect_to action: :index
      return
    end
    product = Product.find_by_id(params[:id])
    if product.blank?
      flash[:alert] = '产品ID有误'
      redirect_to action: :index
      return
    end
    product.soft_delete
    flash[:success] = '置为无效操作完成'
    redirect_to action: :index
  end

  def update_sale_ratio_by_mark
    if request.post?
      begin
        Product.update_sale_ratio_by_mark params[:mark], params[:sale_ratio], current_user.company.id
        flash[:success] = '更新成功'
        redirect_to action: :update_sale_ratio_by_mark
      rescue Exception=>e
        flash[:alert] = dispose_exception e
        render :update_sale_ratio_by_mark
      end
    else
      @marks = current_user.company.marks.split(",")
    end
  end

  def force_update_sale_ratio_by_mark
    begin
      Product.force_update_sale_ratio_by_mark params[:mark_], params[:sale_ratio_], current_user.company.id
      flash[:success] = '更新成功'
      redirect_to action: :update_sale_ratio_by_mark
    rescue Exception=>e
      flash[:alert] = dispose_exception e
      render :update_sale_ratio_by_mark
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