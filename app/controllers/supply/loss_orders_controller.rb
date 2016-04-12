class Supply::LossOrdersController < BaseController
  before_filter :need_login

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

end