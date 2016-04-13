class Supply::LossOrdersController < BaseController
  before_filter :need_login

  def index
    supplier_id = current_user.company.id
    @loss_orders = LossOrder.where("loss_orders.supplier_id = ? and (loss_orders.delete_flag is null or loss_orders.delete_flag = 0)", supplier_id)
    # params[:start_date] ||= Time.now.to_date - 10.days
    # params[:end_date] ||= Time.now.to_date
    unless params[:start_date].blank?
      start_date = params[:start_date].to_time.change(hour:0, min:0, sec:0)
      @loss_orders = @loss_orders.where("loss_orders.loss_date >= ?", start_date)
    end
    unless params[:end_date].blank?
      end_date = params[:end_date].to_time.change(hour:23, min:59, sec:59)
      @loss_orders = @loss_orders.where("loss_orders.loss_date <= ?", end_date)
    end
    unless params[:product_name].blank?
      @loss_orders = @loss_orders.joins(loss_order_items: :product).where("products.chinese_name like ?", "%#{params[:product_name]}%")
    end
    unless params[:memo].blank?
      @loss_orders = @loss_orders.where("loss_orders.memo like ? ", "%#{params[:memo]}%")
    end
    @loss_orders = @loss_orders.order(loss_date: :desc).paginate(page: params[:page]||1, per_page: params[:per_page]||10)
  end

  def edit
    @loss_order = LossOrder.find_by_id(params[:id])
    @loss_order_items = LossOrderItem.where(loss_order_id: params[:id])
  end

  def change_order_item
    begin
      loss_order_item = LossOrderItem.find_by_id(params[:loss_order_item_id])
      loss_order_item.change_order_item params[:real_weight], params[:price], current_user
      render text: 'ok'
    rescue Exception=>e
      render text: 'error'
    end
  end

  def destroy
    begin
      loss_order = LossOrder.find(params[:id])
      success_message = "进货单据ID为#{loss_order.id},日期为#{loss_order.loss_date.strftime("%Y年%m月%d日")},被删除成功。"
      loss_order.delete_self current_user
      flash[:notice] = success_message
      redirect_to action: :index
    rescue Exception=>e
      flash[:alert] = dispose_exception e
      redirect_to "/supply/loss_orders/#{params[:id]}/edit"
    end
  end

  def create_loss_order
    if request.post?
      begin
        # 提交损耗单
        # pp "^"*100
        # pp params
        # {"main_message"=>
        #      "loss_price_id:1|real_weight:1|price:2,loss_price_id:1|real_weight:1|price:3,",
        #  "supplier_id"=>"53",
        #  "memo"=>"",
        #  "loss_type"=>"3",
        #  "loss_date"=>"2016-04-12",
        #  "seller_id"=>"53",
        #  "controller"=>"supply/loss_orders",
        #  "action"=>"create_loss_order"}
        LossOrder.transaction do
          # 创建loss_orders
          store = current_user.store
          BusinessException.raise '当前用户没有绑定门店' if store.blank?
          storage = store.storage
          BusinessException.raise '当前用户所属门店没有绑定仓库' if storage.blank?
          loss_order = LossOrder.new storage_id: storage.id, loss_date: params[:loss_date].to_date, user_id: current_user.id,
                                     delete_flag: 0, supplier_id: current_user.company.id, seller_id: params[:seller_id],
                                     loss_type: params[:loss_type], memo: params[:memo]
          loss_order.save!
          # 创建loss_order_items
          items = params[:main_message].split(',')
          items.each do |item|
            options = item.split('|')
            loss_price_id = options[0].split(':').last
            loss_price = LossPrice.find(loss_price_id)
            param_loss_price = options[2].split(':').last
            BusinessException.raise "#{loss_price.product.chinese_name}价格必须填写数字，且不可以为0" if param_loss_price.to_f == 0
            # 更新loss_price
            loss_price = loss_price.update_price param_loss_price.to_f
            real_weight = options[1].split(':').last
            BusinessException.raise "#{loss_price.product.chinese_name}数量必须填写数字，且不可以为0" if real_weight.to_f == 0
            LossOrderItem.create_and_update_order_detail loss_order_id: loss_order.id,
                                                         product_id: loss_price.product_id,
                                                         real_weight: real_weight,
                                                         loss_price_id: loss_price.id
          end
          render text: "0|保存成功"
        end
      rescue Exception=>e
        render text: "1|#{dispose_exception(e)}"
        return
      end
    else
      # 录入损耗单页面
      params[:loss_date] = Time.now.to_date
      @no_nav = true
      @company = current_user.company
      @marks = Product.where(supplier_id: 31, is_valid:1).group(:mark).order("count(*) desc").count
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
      loss_prices = LossPrice.is_used.where(supplier_id: @company.id).joins(:product)
      @loss_prices = loss_prices.order("products.print_times desc")
      @sellers = Seller.valid.where(supplier_id: @company.id)
    end
  end

  def query_product_by_abc
    @result_products = LossPrice.is_used.where(supplier_id: params[:supplier_id]).joins(:product)
    .where("products.simple_abc like ? or products.chinese_name like ? ", "%#{params[:abc]}%", "%#{params[:abc]}%").order("products.print_times desc")
  end

  def get_price_by_product_name

    if params[:seller_id].blank? || params[:product_name].blank?
      render text: "1|没有指定购买自或产品名"
      return
    end
    supplier = current_user.company
    loss_price = LossPrice.is_used.where(supplier_id: supplier.id).joins(:product)
    .where("products.chinese_name = ?", params[:product_name]).first


    if loss_price.blank?
      render text: "1|该产品没有对应的损耗价格"
      return
    end
    render text: "0|#{loss_price.id}|#{loss_price.true_spec}|#{loss_price.price}"
  end

  def search_item
    unless params[:product_name].blank?
      @loss_items = LossOrderItem.joins(:product)
      @loss_items = @loss_items.where("products.chinese_name like ?", "%#{params[:product_name]}%")
      @loss_items = @loss_items.joins(:loss_order)
      @loss_items = @loss_items.where("loss_orders.supplier_id = ? and (loss_orders.delete_flag is null or loss_orders.delete_flag = 0)", current_user.company.id)
      unless params[:start_date].blank?
        @loss_items = @loss_items.where("loss_date >= ?", params[:start_date].to_time.change(hour:0, min:0, sec:0))
      end
      unless params[:end_date].blank?
        @loss_items = @loss_items.where("loss_date <= ?", params[:end_date].to_time.change(hour:23, min:59, sec:59))
      end
    end
  end
end