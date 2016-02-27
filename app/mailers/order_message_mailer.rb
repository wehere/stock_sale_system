class OrderMessageMailer < ApplicationMailer
  # default from: 'message@591order.com'

  def order_message_email customer_id, supplier_id, content, need_reach_date
    @content = content
    @customer = Company.find(customer_id)
    @need_reach_date = need_reach_date.to_date.to_s(:db)
    address = Company.find(supplier_id).users.collect {|u| u.email}
    mail(to: address.shift, cc: address, subject: "#{@customer.simple_name}的订单")
  end

  def question_order_message content, send_date, order_id
    @order = Order.find(order_id)
    @content = content
    @customer = @order.customer
    @store = @order.store
    @send_date = send_date.to_s(:db)
    address = @order.supplier.users.collect {|u| u.email}
    mail(to: address.shift, cc: address, subject: "#{@customer.simple_name}对我们的单据产生了疑问")
  end

  def reply_question_order_message content, send_date, order_id
    @order = Order.find(order_id)
    @content = content
    @supplier = @order.supplier
    @store = @order.store
    @send_date = send_date.to_s(:db)
    address = @order.customer.users.collect {|u| u.email}
    mail(to: address.shift, cc: address, subject: "来自#{@supplier.simple_name}对单据疑问的回复")
  end

  def send_to_supplier send_order_message_id
    @send_order_message = SendOrderMessage.find_by_id(send_order_message_id)
    address = @send_order_message.supplier.mail_address.split(',')
    mail(to: address.shift, cc: address, subject: "#{@send_order_message.customer.simple_name}-#{@send_order_message.store.name} 的订单")
  end

end
