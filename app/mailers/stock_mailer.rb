class StockMailer < ApplicationMailer

  def negative_stock supplier_id
    @stocks = Stock.where(supplier_id: supplier_id).where("real_weight < 0")
    address = Company.find_by_id(supplier_id).mail_address.split(',')
    mail(to: address.shift, cc: address, subject: "目前库存数量为负数的产品")
  end
end