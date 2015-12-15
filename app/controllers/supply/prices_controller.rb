require 'spreadsheet'
class Supply::PricesController < BaseController
  before_filter :need_login

  def index
    @customers = current_user.company.customers
    @year_months = YearMonth.all
    params[:year_month_id] ||= YearMonth.current_year_month.id

    @prices = current_user.company.all_prices
    @prices = @prices.where(year_month_id: params[:year_month_id]) unless params[:year_month_id].blank?
    @prices = @prices.where(customer_id: params[:customer_id]) unless params[:customer_id].blank?
    unless params[:product_name].blank?
      @prices = @prices.joins(:product) unless @prices.joins_values.include? :product
      @prices = @prices.where("products.chinese_name like ?", "%#{params[:product_name]}%")
    end
    @prices = @prices.paginate(per_page: 6, page: params[:page]||1)
  end

  def need_make_up
    prices = Price.where("ratio is null or ratio = 0 or true_spec is null or true_spec = ''")
    purchase_prices = PurchasePrice.where("ratio is null or ratio =0 or true_spec is null or true_spec = ''")
    a = prices.collect{|x| x.product.general_product.id rescue 0 }
    b = purchase_prices.collect { |x| x.product.general_product.id rescue 0 }
    b.each do |x|
      a << x unless a.include? x
    end
    @general_products = GeneralProduct.where("id in (?) ", a)
    @general_products = @general_products.paginate(page: params[:page]||1, per_page: params[:per_page]||5)
  end

  def do_not_use
    price = Price.find(params[:id])
    price.update_attribute :is_used, false
    @customers = current_user.company.customers
    @year_months = YearMonth.all
    render :index
  end

  def search
    begin
      company = current_user.company
      @customers = company.customers
      @year_months = YearMonth.all
      if request.post?
        @customer_id = params[:customer_id]
        @year_month_id = params[:year_month_id]
        @search_results = company.supply_prices.where(customer_id: params[:customer_id], year_month_id: params[:year_month_id], is_used: true).order(:product_id)
      else
        @customer_id = params[:customer_id]
        @year_month_id = YearMonth.current_year_month.id
        @search_results = nil
      end
    rescue Exception => e
      flash[:alert] = '查询失败，' + dispose_exception(e)
    end
  end

  def prepare_create_price
    redirect_to '/supply/products'
  end

  def new
    puts params
    company = current_user.company
    @product_id = params[:product_id]
    @chinese_name = Product.find(@product_id).chinese_name
    @supplier_id = company.id
    @customers = company.customers
    @year_months = YearMonth.all
    @year_month_id = YearMonth.current_year_month.id
  end

  def create
    begin
      Price.create! price_params.merge(is_used: true)
      flash[:success] = '创建成功'
      redirect_to search_supply_prices_path, method: :get
    rescue Exception => e
      flash[:alert] = dispose_exception e
      company = current_user.company
      @product_id = params[:product_id]
      @chinese_name = Product.find(@product_id).chinese_name
      @supplier_id = company.id
      @customers = company.customers
      @year_months = YearMonth.all
      @year_month_id = YearMonth.current_year_month.id
      render :new
    end
  end

  def update_one_price
    price = Price.find_by_id(params[:id]) rescue nil
    unless price.blank?
      if params[:price].blank?
        unless price.true_spec.equal? params[:spec]
          unless params[:spec].blank?
            price.update_attribute :true_spec, params[:spec]
          end
        end
      else
        unless price.price.equal? params[:price].to_f
          unless params[:price].blank?
            new_price = price.dup
            price.update_attribute :is_used, false
            new_price.update_attribute :price, params[:price]
          end
        end
      end

    end
    render :text => 'ok'
  end

  def update
    begin
      @old_price = Price.find(params[:id])
      unless @old_price.price.equal? params[:submitted_price].to_f
        new_price = @old_price.dup
        @old_price.update_attribute :is_used, false
        new_price.update_attributes! price: params[:submitted_price].to_f, true_spec: params[:submitted_spec]
        flash[:notice] = '更新成功'
      else
        @old_price.update_attribute :true_spec, params[:submitted_spec]
        flash[:notice] = '更新成功'
      end
    rescue Exception => e
      flash[:notice] = dispose_exception e
    end
    company = current_user.company
    @customers = company.customers
    @year_months = YearMonth.all
    @customer_id = @old_price.customer_id
    @year_month_id = @old_price.year_month_id
    @search_results = company.supply_prices.where(customer_id: @customer_id, year_month_id: @year_month_id, is_used: true).order(:product_id)
    @pos_id = params[:pos_id].to_i - 1
    render :search
  end

  def true_update_price
    begin
      true_price = Price.find(params[:id])
      true_price.update_attributes! price: params[:price].to_f, true_spec: params[:true_spec]
      flash[:notice] = '更新成功'
      redirect_to null_price_supply_order_items_path
    rescue Exception => e
      flash[:alert] = dispose_exception e
      redirect_to null_price_supply_order_items_path
    end
  end

  def generate_next_month
    begin
      YearMonth.generate_recent_year_months
      if request.post?
        prices = Price.where(is_used: true, year_month_id: params[:origin_year_month_id], supplier_id: current_user.company.id)
        Price.generate_next_month_batch prices, params[:target_year_month_id]
        flash[:notice] = "成功"
        redirect_to search_supply_prices_path, method: :get
      else
        @year_months = YearMonth.all.order(:id)
        @target_year_month_id = YearMonth.next_year_month.id
        @origin_year_month_id = YearMonth.current_year_month.id
      end
    rescue Exception => e
      flash[:alert] = dispose_exception e
      redirect_to generate_next_month_supply_prices_path
    end
  end

  def import_prices_from_xls
    @year_months = YearMonth.all
    @year_month_id = YearMonth.current_year_month.id
    company = current_user.company
    @customers = company.customers
    if request.post?
      supplier_id = current_user.company.id
      customer_id = params[:customer_id]
      year_month_id = params[:year_month_id]
      file_io = params[:price_xls]
      flash[:alert] = Price.import_prices_from_xls supplier_id, customer_id, year_month_id, file_io
      redirect_to import_prices_from_xls_supply_prices_path
    end
  end

  def export_xls_of_prices
    @supplier_id = current_user.company.id
    @customers = current_user.company.customers.order(:simple_name)
    @year_months = YearMonth.all.order(:id)
    @current_year_month_id = params[:year_month_id] || YearMonth.current_year_month.id
    if request.post?
      begin
        file_name = Price.export_xls_of_prices @supplier_id, params[:id], params[:year_month_id]
        if File.exists? file_name
          io = File.open(file_name)
          io.binmode
          send_data io.read, filename: file_name, disposition: 'inline'
          io.close
          File.delete file_name
        else
          flash[:alert] = '文件不存在！'
          redirect_to export_xls_of_prices_supply_prices_path
        end
      rescue Exception => e
        flash[:alert] = dispose_exception e
        render :export_xls_of_prices
      end
    end
  end

#################################
  def show_price
    month = "#{Time.now.year}年#{Time.now.month}月"
    @prices = Price.query_price is_used: true,
                                product_name: params[:product_name],
                                supplier_id: current_user.company.id,
                                per_page: 10,
                                month: month,
                                page: params[:page]


  end

  def save_data
    permitted = params.permit(p: [:price, :ratio, :true_spec])
    params.permit(:id)
    price = Price.find params[:id]
    # result = begin
    new_price = price.update_price permitted[:p]

    result = {
        :code => 0,
        :status => '存储数据成功',
        :price => new_price.price,
        :true_spec => new_price.true_spec,
        :ratio => new_price.ratio
    }
    # rescue Exception => e
    #   {:code => 1,
    #    :status => '失败'}
    # end
    render :json => result.to_json
  end


  private
  def price_params
    params.permit([:year_month_id, :customer_id, :product_id, :price, :true_spec, :supplier_id])
  end
end
