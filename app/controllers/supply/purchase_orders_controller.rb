class Supply::PurchaseOrdersController < BaseController
  before_filter :need_login

  def index
    supplier_id = current_user.company.id
    @purchase_orders = PurchaseOrder.where("purchase_orders.supplier_id = ? and (purchase_orders.delete_flag is null or purchase_orders.delete_flag = 0)", supplier_id)
    # params[:start_date] ||= Time.now.to_date - 10.days
    # params[:end_date] ||= Time.now.to_date
    unless params[:start_date].blank?
      start_date = params[:start_date].to_time.change(hour:0, min:0, sec:0)
      @purchase_orders = @purchase_orders.where("purchase_orders.purchase_date >= ?", start_date)
    end
    unless params[:end_date].blank?
      end_date = params[:end_date].to_time.change(hour:23, min:59, sec:59)
      @purchase_orders = @purchase_orders.where("purchase_orders.purchase_date <= ?", end_date)
    end
    unless params[:product_name].blank?
      @purchase_orders = @purchase_orders.joins(purchase_order_items: :product).where("products.chinese_name like ?", "%#{params[:product_name]}%")
    end
    unless params[:memo].blank?
      @purchase_orders = @purchase_orders.where("purchase_orders.memo like ? ", "%#{params[:memo]}%")
    end
    @purchase_orders = @purchase_orders.order(updated_at: :desc).paginate(page: params[:page]||1, per_page: params[:per_page]||10)
  end

  def edit
    @purchase_order = PurchaseOrder.find_by_id(params[:id])
    @purchase_order_items = PurchaseOrderItem.where(purchase_order_id: params[:id])
  end

  def edit_seller
    need_admin
    @purchase_order = PurchaseOrder.find_by_id(params[:id])
    @sellers = Seller.valid.where(supplier_id: current_user.company.id)
  end

  def update_seller
    need_admin
    begin
      purchase_order = PurchaseOrder.find_by_id(params[:id])
      purchase_order.update_seller params[:seller_id]
      flash[:success] = '更新成功'
      redirect_to "/supply/purchase_orders/#{purchase_order.id}/edit"
    rescue Exception => e
      flash[:alert] = dispose_exception e
      @purchase_order = PurchaseOrder.find_by_id(params[:id])
      @sellers = Seller.valid.where(supplier_id: current_user.company.id)
      render :edit_seller
    end
  end

  def change_order_item
    begin
      purchase_order_item = PurchaseOrderItem.find_by_id(params[:purchase_order_item_id])
      purchase_order_item.change_order_item params[:real_weight], params[:price], current_user
      render text: 'ok'
    rescue Exception=>e
      render text: 'error'
    end
  end

  def destroy
    begin
      purchase_order = PurchaseOrder.find(params[:id])
      success_message = "进货单据ID为#{purchase_order.id},日期为#{purchase_order.purchase_date.strftime("%Y年%m月%d日")},被删除成功。"
      purchase_order.delete_self current_user
      flash[:notice] = success_message
      redirect_to action: :index
    rescue Exception=>e
      flash[:alert] = dispose_exception e
      redirect_to "/supply/purchase_orders/#{params[:id]}/edit"
    end
  end

  def search_item
    unless params[:product_name].blank?
      @purchase_items = PurchaseOrderItem.joins(:product)
      @purchase_items = @purchase_items.where("products.chinese_name like ?", "%#{params[:product_name]}%")
      @purchase_items = @purchase_items.joins(:purchase_order)
      @purchase_items = @purchase_items.where("purchase_orders.supplier_id = ? and (purchase_orders.delete_flag is null or purchase_orders.delete_flag = 0)", current_user.company.id)
      unless params[:start_date].blank?
        @purchase_items = @purchase_items.where("purchase_date >= ?", params[:start_date].to_time.change(hour:0, min:0, sec:0))
      end
      unless params[:end_date].blank?
        @purchase_items = @purchase_items.where("purchase_date <= ?", params[:end_date].to_time.change(hour:23, min:59, sec:59))
      end
    end
  end

  def create_purchase_order
    if request.post?
      # pp "^"*100
      # pp params
      # {"main_message"=>
      #      "purchase_price_id:2810|real_weight:1|price:5,purchase_price_id:2811|real_weight:1|price:8,",
      #  "supplier_id"=>"53",
      #  "memo"=>"ccc",
      #  "purchase_date"=>"2016-04-16",
      #  "seller_id"=>"53",
      #  "controller"=>"supply/purchase_orders",
      #  "action"=>"create_purchase_order"}
      begin
        PurchaseOrder.transaction do
          percent = SystemConfig.v('允许浮动的差价百分比', '10').to_f
          # 创建purchase_orders
          store = current_user.store
          BusinessException.raise '当前用户没有绑定门店' if store.blank?
          storage = store.storage
          BusinessException.raise '当前用户所属门店没有绑定仓库' if storage.blank?
          purchase_order = PurchaseOrder.new storage_id: storage.id, purchase_date: params[:purchase_date].to_date, user_id: current_user.id,
                                     delete_flag: 0, supplier_id: current_user.company.id, seller_id: params[:seller_id], memo: params[:memo]
          purchase_order.save!
          # 创建purchase_order_items
          items = params[:main_message].split(',')
          items.each do |item|
            options = item.split('|')

            # 更新loss_price
            purchase_price_id = options[0].split(':').last
            purchase_price = PurchasePrice.find(purchase_price_id)
            param_purchase_price = options[2].split(':').last
            BusinessException.raise "#{purchase_price.product.chinese_name}价格必须填写数字，且不可以为0" if param_purchase_price.to_f == 0

            # 检测价格是否有问题
            general_product = purchase_price.product.general_product
            if !general_product.current_purchase_price.blank? && general_product.current_purchase_price != 0
              BusinessException.raise "#{purchase_price.product.chinese_name}价格比上一次价格浮动超过#{percent}%，上次价格是#{general_product.current_purchase_price}" if general_product.need_check && ((general_product.current_purchase_price-param_purchase_price.to_f)/general_product.current_purchase_price).abs > percent/100.0
              general_product.update_attributes need_check: true
            end

            purchase_price = purchase_price.update_price param_purchase_price.to_f

            real_weight = options[1].split(':').last
            BusinessException.raise "#{purchase_price.product.chinese_name}数量必须填写数字，且不可以为0" if real_weight.to_f == 0
            # 创建purchase_order_item  创建order_detail  更新stock
            PurchaseOrderItem.create_and_update_order_detail purchase_order_id: purchase_order.id,
                                                         product_id: purchase_price.product_id,
                                                         real_weight: real_weight,
                                                         purchase_price_id: purchase_price.id
          end
          render text: "0|保存成功"
        end
      rescue Exception=>e
        render text: "1|#{dispose_exception(e)}"
      end
    else
      # 录入进货单页面
      params[:purchase_date] = Time.now.to_date
      @no_nav = true
      @company = current_user.company
      @marks = Product.where(supplier_id: @company.id, is_valid:1).group(:mark).order("count(*) desc").count
      #{"干货"=>117, "蔬菜"=>53, "冻品"=>37, "调料"=>28, "肉类"=>18, "豆制品"=>10, "水产品"=>9, "菇类"=>5, "面类"=>4, "水果"=>4, "杂货"=>3, "未分类"=>1}
      @big_marks = []
      @small_marks = []
      @marks.each do |k, v|
        if @big_marks.size < 5
          @big_marks << k
        else
          @small_marks << k
        end
      end
      purchase_prices = PurchasePrice.available.where(supplier_id: @company.id).joins(:product)
      @purchase_prices = purchase_prices.order("products.print_times desc")
      @sellers = Seller.valid.where(supplier_id: @company.id)
    end
  end

  def get_price_by_product_name
    if params[:seller_id].blank? || params[:product_name].blank?
      render text: "1|没有指定购买自或产品名"
      return
    end
    supplier = current_user.company
    purchase_price = PurchasePrice.available.where(supplier_id: supplier.id).joins(:product)
    .where("products.chinese_name = ?", params[:product_name]).first


    if purchase_price.blank?
      render text: "1|该产品没有对应的损耗价格"
      return
    end
    render text: "0|#{purchase_price.id}|#{purchase_price.true_spec}|#{purchase_price.price}"
  end

  def query_product_by_abc
    @result_products = PurchasePrice.available.where(supplier_id: params[:supplier_id]).joins(:product)
    .where("products.simple_abc like ? or products.chinese_name like ? ", "%#{params[:abc]}%", "%#{params[:abc]}%").order("products.print_times desc")
  end
end
