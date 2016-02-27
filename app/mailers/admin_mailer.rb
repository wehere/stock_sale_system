class AdminMailer < ApplicationMailer
  # default from: "message@591order.com"

  def product_repeated product_names
    @product_names = product_names
    mail(to: '549174542@qq.com', subject: "单子重复")
  end
end