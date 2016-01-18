class Supply::OrdersController < BaseController
  before_filter :need_login
  def index
    @key = params[:key]

    @orders = current_user.company.in_orders.valid_orders
    unless params[:date_start].blank?
      @orders = @orders.where("reach_order_date>=?", params[:date_start].to_time.change(hour:0,min:0,sec:0))
    end
    unless params[:date_end].blank?
      @orders = @orders.where("reach_order_date<=?", params[:date_end].to_time.change(hour:23,min:59,sec:59))
    end
    @orders = @orders.where(customer_id: params[:customer_id]) unless params[:customer_id].blank?
    @orders = @orders.where(store_id: params[:store_id]) unless params[:store_id].blank?
    unless @key.blank?
      company = Company.find_by_simple_name(@key)
      @orders = @orders.where("id = ? or customer_id = ? or customer_id = ?", @key, @key, company.blank? ? nil : company.id)
    end
    @orders = @orders.paginate(page: params[:page], per_page: 10)
  end

  def destroy
    supplier_id = current_user.company.id
    order = Order.where(supplier_id:supplier_id).find_by_id(params[:id])
    if order.is_confirm
      flash[:alert] = '该单据已经出库确认了，不可以删除。'
    else
      order.update_attribute :delete_flag, 1
      flash[:notice] = '删除成功'
    end
    redirect_to action: :index
  end

  def save_real_price
    begin
      order_item = OrderItem.find(params[:order_item_id])
      price = order_item.price
      price.update_attribute :price, params[:real_price] if price.price.blank? || price.price == 0.0
      g_price = price.dup
      g_price.update_attribute :price, params[:real_price]
      g_price.update_attribute :is_used, false
      order_item.update_attribute :price_id, g_price.id
      order_item.update_money
      render text: g_price.price.to_s
    rescue Exception=>e
      render text: dispose_exception(e)
    end
  end

  def edit
    begin
    supplier_id = current_user.company.id
    if params[:id] == "0"
      @order = Order.valid_orders.where(supplier_id: supplier_id).first
    else
      @order = Order.valid_orders.where(supplier_id: supplier_id).find_by_id(params[:id])
    end

    # @pre_order = @order.previous @order.order_type.previous
    # @next_order = @order.next @order.order_type.next
    @order_items = @order.order_items
    rescue Exception=> e
      flash[:alert] = '找不到该单据'
      redirect_to action: :index
    end
  end

  def update
    supplier_id = current_user.company.id
    begin
      order = Order.valid_orders.where(supplier_id: supplier_id).find_by_id(params[:order_id])
      hash = params[:order_item]
      Order.transaction do
        hash.each do |key,value|
          order_item = OrderItem.find(key)

            order_item.update_attribute :real_weight, value.blank? ? 0 : value
            order_item.update_money
            if !order.is_confirm
              # 更新进出明细
              order_item.update_detail current_user
              # 更新库存stocks
              order_item.update_stock current_user
            else
              order_item.change_detail_and_stock current_user
            end
        end
      end

      order.update_attributes is_confirm: true unless order.is_confirm
      order.calculate_not_input_number
      flash[:notice] = "更新成功"
      redirect_to "/supply/orders/#{params[:order_id]}/edit?t=#{Time.now.to_i}"
    rescue Exception=>e
      flash[:alert] = dispose_exception e
      redirect_to "/supply/orders/#{params[:order_id]}/edit?t=#{Time.now.to_i}"
    end
  end

  def comment
    begin
      comment = Comment.create! order_id: params[:order_id], content: params[:content], user_id: current_user.id
      OrderMessageMailer.reply_question_order_message(params[:content],comment.created_at,params[:order_id]).deliver
      redirect_to edit_supply_order_path(params[:order_id])
    rescue Exception => e
      flash[:alert] = dispose_exception e
      redirect_to edit_supply_order_path(params[:order_id])
    end
  end

  def not_input
      supplier_id = current_user.company.id
      @orders = Order.common_query(params.permit(:start_date, :end_date, :allowed_number_not_input, :customer_id, :not_customer_id).merge(supplier_id: current_user.company.id))
      @orders = @orders.where("orders.not_input_number > ?", 0) if params[:allowed_number_not_input].blank?
      @orders = @orders.paginate(page: params[:page], per_page: 10)

  end

  def return
    supplier_id = current_user.company.id
    Order.where(supplier_id: supplier_id).find_by_id(params[:id]).return
    render :text => "ok"
  end

  def not_return
    @orders = Order.common_query(params.permit(:start_date, :end_date, :customer_id, :not_customer_id).merge(supplier_id: current_user.company.id))
    @orders = @orders.not_return_orders
    @orders = @orders.paginate(page: params[:page], per_page: 10)
  end

  def pre_confirm_back_order

  end

  def confirm_back_order
    supplier_id = current_user.company.id
    order = Order.where(supplier_id: supplier_id).find_by_id(params[:order_id])
    if order.blank?
      render text: '找不到对应的单据。'
    else
      order.return
      render text: "单据#{params[:order_id]} 更新成功"
    end
  end

  def got_orders
    params[:start_date] ||= Time.now.tomorrow.to_date
    params[:end_date] ||= Time.now.tomorrow.to_date
    params[:dealt_status] ||= false
    @messages = if params[:dealt_status].blank?
                  SendOrderMessage.is_valid
                elsif params[:dealt_status]
                  SendOrderMessage.is_valid.is_dealt
                else
                  SendOrderMessage.is_valid.not_dealt
                end
    @messages = @messages.where(supplier_id: current_user.company.id)
    @messages = @messages.where("reach_date >= ?", params[:start_date].to_time.change(hour:0,min:0,sec:0)) unless params[:start_date].blank?
    @messages = @messages.where("reach_date <= ?", params[:end_date].to_time.change(hour:23,min:59,sec:59)) unless params[:end_date].blank?
  end

  def send_message_dealt
    message = SendOrderMessage.find(params[:id])
    message.update_attribute :is_dealt, true
    redirect_to "/supply/orders/got_orders?start_date=#{params[:start_date]}&end_date=#{params[:end_date]}&dealt_status=#{params[:dealt_status]}"
  end


  def send_out_orders
    begin
      if current_user.store.blank?
        flash[:alert] = '当前用户未绑定门店'
        redirect_to '/vis/static_pages/welcome'
        return
      end
      params[:start_date] ||= Time.now.tomorrow.to_date
      params[:end_date] ||= Time.now.tomorrow.to_date
      params[:dealt_status] ||= false
      @messages = if params[:dealt_status].blank?
                    SendOrderMessage.is_valid
                  elsif params[:dealt_status]
                    SendOrderMessage.is_valid.is_dealt
                  else
                    SendOrderMessage.is_valid.not_dealt
                  end
      @messages = @messages.where(store_id: current_user.store_id)
      @messages = @messages.where("reach_date >= ?", params[:start_date].to_time.change(hour:0,min:0,sec:0)) unless params[:start_date].blank?
      @messages = @messages.where("reach_date <= ?", params[:end_date].to_time.change(hour:23,min:59,sec:59)) unless params[:end_date].blank?
    rescue Exception => e
      flash[:alert] = dispose_exception e
      redirect_to '/vis/static_pages/welcome'
    end
  end

  def send_out_order_delete
    message = SendOrderMessage.find(params[:id])
    message.update_attribute :is_valid, false
    redirect_to "/supply/orders/send_out_orders?start_date=#{params[:start_date]}&end_date=#{params[:end_date]}&dealt_status=#{params[:dealt_status]}"
  end

end

# Parameters: {"order_id"=>"80",
# "order_item"=>{"98"=>[""], "99"=>[""], "100"=>[""], "101"=>[""], "102"=>[""], "103"=>[""], "104"=>[""], "105"=>[""], "106"=>[""], "107"=>[""], "108"=>[""]}, "commit"=>"提交", "id"=>"80"}
# User Load (39.5ms)  SELECT  `users`.* FROM `users`  WHERE `users`.`id` = 1  ORDER BY `users`.`id` ASC LIMIT 1