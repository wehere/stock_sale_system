# == Schema Information
#
# Table name: purchase_orders
#
#  id            :integer          not null, primary key
#  storage_id    :integer
#  purchase_date :datetime
#  user_id       :integer
#  delete_flag   :boolean
#  created_at    :datetime
#  updated_at    :datetime
#  supplier_id   :integer
#  seller_id     :integer
#  memo          :string(500)
#

class PurchaseOrder < ActiveRecord::Base

  has_many :purchase_order_items
  belongs_to :seller

  def self.export_purchase_order  start_date, end_date, supplier_id
    start_date = start_date.to_time.change(hour: 0, min: 0, sec: 0)
    end_date = end_date.to_time.change(hour: 23, min: 59, sec: 59)
    purchase_orders = self.where( "supplier_id = ? and ( delete_flag is null or delete_flag = 0 ) and purchase_date between ? and ?", supplier_id, start_date, end_date).order(:purchase_date)
    Spreadsheet.client_encoding = "UTF-8"
    book = Spreadsheet::Workbook.new
    sheet = book.create_worksheet name: '进仓明细'
    in_center = Spreadsheet::Format.new horizontal_align: :center, vertical_align: :center, border: :thin
    sheet.merge_cells(0,0,0,2)
    sheet.row(0)[0] = "#{start_date.to_date.to_s(:db)}至#{end_date.to_date.to_s(:db)}进货单据明细"
    sheet.row(1).push '单据ID', '日期', '金额'
    current_row = 2
    sum = 0.0
    purchase_orders.each do |p|
      sheet.row(current_row).push p.id, p.purchase_date.strftime("%Y年%m月%d日"), p.sum_money
      sum += p.sum_money
      current_row += 1
    end
    sheet.row(current_row).push '合计', '',  sum
    0.upto 2 do |x|
      0.upto current_row do |y|
        sheet.row(y).set_format(x, in_center)
      end
    end
    file_path = Rails.root.join("public","downloads/#{supplier_id}/", "#{start_date.to_date.to_s(:db)}至#{end_date.to_date.to_s(:db)}进货单据明细.xls")
    Dir.mkdir Rails.root.join("public","downloads/#{supplier_id}/") unless Dir.exist? Rails.root.join("public","downloads/#{supplier_id}/")
    book.write file_path
    file_path
  end

  def sum_money
    PurchaseOrder.joins(:purchase_order_items).where(id: self.id).sum("purchase_order_items.money").round(2)
  end

  def delete_self current_user
    PurchaseOrder.transaction do
      self.purchase_order_items.each do |poi|
        poi.delete_self current_user, false
      end
      self.update_attributes delete_flag: 1
    end
  end

  def update_seller seller_id
    seller = Seller.find(seller_id)
    self.seller = seller
    self.save!
  end
end
